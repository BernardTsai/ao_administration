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

# ----- install portainer ------------------------------------------------------
echo Install Portainer

docker ps -a | grep portainer > /dev/null 2>&1
if [ $? -eq 1 ]
then
  sudo docker run --detach \
      --name portainer \
      --publish 9000:9000 \
      --restart unless-stopped \
      --volume /var/run/docker.sock:/var/run/docker.sock \
      portainer/portainer
fi

# ----- install GitLab ---------------------------------------------------------
echo Install GitLab

docker ps -a | grep gitlab > /dev/null 2>&1
if [ $? -eq 1 ]
then
  sudo docker run --detach \
      --hostname gitlab.example.com \
      --publish 443:443 --publish 80:80 --publish 22:22 \
      --name gitlab \
      --restart always \
      --volume /srv/gitlab/config:/etc/gitlab \
      --volume /srv/gitlab/logs:/var/log/gitlab \
      --volume /srv/gitlab/data:/var/opt/gitlab \
      gitlab/gitlab-ce:latest
fi

# determine ip address
export gitlab_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gitlab)

# ----- install model ----------------------------------------------------------
echo Install Model

docker ps -a | grep model > /dev/null 2>&1
if [ $? -eq 1 ]
then
  # build docker image
  cat > Dockerfile <<EOF
FROM alpine:latest

MAINTAINER Bernard Tsai <bernad@tsai.eu>

RUN apk --update add --no-cache openssh bash git curl \
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
    && pip install jinja2 \
    && python setup.py install

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
EOF

  # build docker image
  sudo docker build -t model .

  # run docker image
  sudo docker run --detach \
      --name model \
      --add-host=gitlab:$gitlab_ip \
      --restart unless-stopped \
      model

  # cleanup
  rm Dockerfile
fi

# determine ip address
export model_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' model)

# ----- install AWX ------------------------------------------------------------
echo Install AWX

docker ps -a | grep awx_web > /dev/null 2>&1
if [ $? -eq 1 ]
then
  # clone AWX repository
  git clone https://github.com/ansible/awx.git

  # change port to 81
  cd awx/installer
  sed -i 's/host_port=80/host_port=81/' inventory

  # start installer ansible playbook
  sudo ansible-playbook -i inventory install.yml

  # add hosts
  sudo docker exec -it awx_web  sh -c "echo $gitlab_ip gitlab >> /etc/hosts"
  sudo docker exec -it awx_web  sh -c "echo $model_ip  model  >> /etc/hosts"
  sudo docker exec -it awx_task sh -c "echo $gitlab_ip gitlab >> /etc/hosts"
  sudo docker exec -it awx_task sh -c "echo $model_ip  model  >> /etc/hosts"

  # cleanup
  cd ../..
  rm -rf awx
fi

# ----- Server configuration completed -----------------------------------------
echo Finished
