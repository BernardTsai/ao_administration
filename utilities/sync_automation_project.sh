#!/bin/bash

# ------------------------------------------------------------------------------
#
# sync_automation_project.sh
#
# Author: Bernard Tsai (mailto:bernard@tsai.eu)
#
# BASH script to configure GitLab (password/tokoens/groups/projects).
#
# Usage: ./sync_automation_project.sh
#
# ------------------------------------------------------------------------------
echo Resync Automation Project

# remove old repository
docker exec gitlab rm -rf /var/opt/gitlab/git-data/repositories/Tools/automation.git
docker exec gitlab rm -rf /var/opt/gitlab/git-data/repositories/Tools/automation.wiki.git

# build configuration script
cat > sync_automation_project.rb <<EOF
# Get admin user
user = User.where(id: 1).first

# Get Tools group
group = Group.where(name: 'Tools')

# Get old automation project
project = Project.where(name: 'automation')

# Delete old automation project
Project.delete(project)

# Delete old route
route = Route.where(path:'Tools/automation')
Route.delete(route)

# Create 'Tools/automation' project
project = Project.new(creator: user, namespace_id: group.ids[0], name:'automation', path:'automation', visibility: 'public', import_url: 'https://github.com/BernardTsai/ao_automation.git')
project.save!
project.import_schedule!
project.import_start!
project.import_finish!
EOF

# copy configuration to container
docker cp sync_automation_project.rb gitlab:/sync_automation_project.rb

# apply configuration script
docker exec gitlab gitlab-rails runner -e production /sync_automation_project.rb 2> /dev/null

# cleanup
rm sync_automation_project.rb

# authenticating to AWX
echo Authenticating

export HEADER1="Content-Type: application/json"
export DATA='{"username":"admin", "password":"password"}'
export TOKEN=$(curl -s -d "$DATA" -H "$HEADER1" http://localhost:81/api/v2/authtoken/ | jq -r ".token")

echo $TOKEN

# get project
echo Get Project

export HEADER1="Content-Type: application/json"
export HEADER2="Authorization: Token $TOKEN"
export PROJECT=$(curl -s -H "$HEADER1" -H "$HEADER2" http://localhost:81/api/v2/projects/?name=automation | jq -r ".results[0].id")

echo $PROJECT

# update project
echo Update Project

export HEADER1="Content-Type: application/json"
export HEADER2="Authorization: Token $TOKEN"
export RESULT=$(curl -s -X POST -H "$HEADER1" -H "$HEADER2" "http://localhost:81/api/v2/projects/$PROJECT/update")

echo $RESULT

# Server configuration completed
echo Finished
