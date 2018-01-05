#!/bin/bash

# ------------------------------------------------------------------------------
#
# sync_example_project.sh
#
# Author: Bernard Tsai (mailto:bernard@tsai.eu)
#
# BASH script to reload example project.
#
# Usage: ./sync_example_project.sh
#
# ------------------------------------------------------------------------------
echo Resync Automation Project

# remove old repository
docker exec gitlab rm -rf /var/opt/gitlab/git-data/repositories/Applications/example.git
docker exec gitlab rm -rf /var/opt/gitlab/git-data/repositories/Applications/example.wiki.git

# build configuration script
cat > sync_automation_project.rb <<EOF
# Get admin user
user = User.where(id: 1).first

# Get Tools group
group = Group.where(name: 'Applications')

# Get old automation project
project = Project.where(name: 'example')

# Delete old automation project
Project.delete(project)

# Delete old route
route = Route.where(path:'Applications/example')
Route.delete(route)

# Create 'Application/example' project
project = Project.new(creator: user, namespace_id: group.ids[0], name:'example', path:'automation', visibility: 'public', import_url: 'https://github.com/BernardTsai/ao_example.git')
project.save!
project.import_schedule!
project.import_start!
project.import_finish!
EOF

# copy configuration to container
docker cp sync_automation_project.rb gitlab:/sync_example_project.rb

# apply configuration script
docker exec gitlab gitlab-rails runner -e production /sync_example_project.rb 2> /dev/null

# cleanup
rm sync_example_project.rb

# Server configuration completed
echo Finished
