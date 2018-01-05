#!/bin/bash

# ------------------------------------------------------------------------------
#
# 01_configure_server.sh
#
# Author: Bernard Tsai (mailto:bernard@tsai.eu)
#
# BASH script to configure server for hosting a docker engine.
#
# Usage: ./01_configure_server.sh
#
# ------------------------------------------------------------------------------
echo Configuring server

# update repositories
echo Updating repositories
sudo apt-get update

# enable https access
echo Enable apt https access
sudo apt-get -y install \
     apt-transport-https \
     ca-certificates \
     curl \
     software-properties-common

 # install jq
 echo Install sshuttle
 sudo apt-get -y install sshuttle

# install jq
echo Install jq
sudo apt-get -y install jq

# install git
echo Install git
sudo apt-get -y install git

# install python3 and pip
echo Install python3 and pip
sudo apt-get -y install python3 python3-pip

# install ansible
echo Install ansible
sudo pip install ansible

# install docker
echo Install docker
sudo apt-get remove docker docker-engine docker.io
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get -y install docker-ce

# Server configuration completed
echo Finished
