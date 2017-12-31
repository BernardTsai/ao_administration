#!/bin/bash

# ------------------------------------------------------------------------------
#
# 03_define_credentials.sh
#
# Author: Bernard Tsai (mailto:bernard@tsai.eu)
#
# BASH script to customize the GitLab access credentials.
#
# Usage: ./03_define_credentials.sh
#
# ------------------------------------------------------------------------------
echo Define credentials

echo URL of the OpenStack API endpoint:
read endpoint

echo Password of the OpenStack administrator:
read password

echo Person access token of the GitLab administrator:
read token

echo Render inventory.yaml
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cat $dir/inventory.tmpl | sed "s/{{endpoint}}/$endpoint/g" \
                        | sed "s/{{password}}/$password/g" \
                        | sed "s/{{token}}/$token/g"       > $dir/inventory.yaml

# Server configuration completed
echo Finished
