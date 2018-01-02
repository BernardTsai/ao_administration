#!/bin/bash

# ------------------------------------------------------------------------------
#
# 99_cleanup_containers.sh
#
# Author: Bernard Tsai (mailto:bernard@tsai.eu)
#
# BASH script to delete docker contariners, volumes and images.
#
# Usage: ./99_cleanup_containers.sh
#
# ------------------------------------------------------------------------------
echo Cleanup containers

# Remove containers
echo Remove containers
sudo docker stop $(docker ps -a -q) > /dev/null 2>&1
sudo docker rm $(docker ps -a -q)   > /dev/null 2>&1

# Remove volumes
echo Remove volumes
sudo docker volume rm `docker volume ls -q -f dangling=true`
sudo rm -rf /tmp/pgdocker 2>&1 > /dev/null
sudo rm -rf /srv/gitlab   2>&1 > /dev/null

# Remove images
echo Remove images
sudo docker rmi $(docker images -q) > /dev/null 2>&1

# Containers, volumes and images have been removed
echo Finished
