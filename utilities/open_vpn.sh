#!/bin/bash

# ------------------------------------------------------------------------------
#
# open_vpn.sh
#
# Author: Bernard Tsai (mailto:bernard@tsai.eu)
#
# BASH script to configure GitLab (password/tokoens/groups/projects).
#
# Usage: ./open_vpn.sh <jumphost> <cidr>
#
# ------------------------------------------------------------------------------
echo Opening VPN Connection

# remove old repository
sshuttle -l 0.0.0.0 -r $1 $2

# Server configuration completed
echo Closing VPN Connection
