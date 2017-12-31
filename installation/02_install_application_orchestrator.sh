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

# sudo docker run --detach \
#     --name model \
#     model

# install portainer
echo Install Portainer

sudo docker run --detach \
    --name portainer \
    --publish 9000:9000 \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    portainer/portainer

# Server configuration completed
echo Finished
