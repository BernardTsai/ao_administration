#!/bin/bash

# ------------------------------------------------------------------------------
#
# 02_install_application_orchestrator.sh
#
# Author: Bernard Tsai (mailto:bernard@tsai.eu)
#
# BASH script to install a simple application orchestrator onto a local
# docker engine..
#
# Usage: ./02_install_application_orchestrator.sh
#
# ------------------------------------------------------------------------------
echo Configuring server

# install GitLab
echo Install GitLab

sudo docker run --detach \
    --hostname gitlab.example.com \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest

# install AWX
echo Install AWX

# clone AWX repository
git clone https://github.com/ansible/awx.git

# change port to 81
cd awx/installer
sed -i 's/host_port=80/host_port=81/' inventory

# start installer ansible playbook
sudo ansible-playbook -i inventory install.yml

# install model
echo Install Model

# build docker image
cat > Dockerfile <<EOF
FROM alpine:latest

MAINTAINER Bernard Tsai <bernad@tsai.eu>

RUN apk --update add --no-cache openssh bash git \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:password" | chpasswd \
  && rm -rf /var/cache/apk/*
RUN sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
RUN sed -ri 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config
RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key

RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

RUN git clone https://github.com/BernardTsai/ao_model.git \
    && cd ao_model \
    && python setup.py install

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
EOF

# build docker image
sudo docker build -t model .

# run docker image
sudo docker run --detach --name model model

# install portainer
echo Install Portainer

sudo docker run --detach \
    --name portainer \
    --publish 9000:9000 \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    portainer/portainer

# Server configuration completed
echo Finished
