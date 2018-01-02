#!/bin/bash

# ------------------------------------------------------------------------------
#
# 03_configure_gitlab.sh
#
# Author: Bernard Tsai (mailto:bernard@tsai.eu)
#
# BASH script to configure GitLab (password/tokoens/groups/projects).
#
# Usage: ./03_configure_gitlab.sh
#
# ------------------------------------------------------------------------------
echo Define Password/Token/Groups and Projects

# build configuration script
cat > gitlab_configuration.rb <<EOF
# Change root password
user                       = User.where(id: 1).first
user.password              = 'password'
user.password_confirmation = 'password'
user.save!

# Create access token
token = PersonalAccessToken.new(user: user, name: 'token', token: 'gitlab_token', scopes: Gitlab::Auth::API_SCOPES)
token.save!

# Create 'Tools' group
group = Group.new(name:'Tools', path: 'Tools', visibility: 'public')
group.save!

# Create 'Tools/automation' project
project = Project.new(creator: user, namespace_id: group.id, name:'automation', path:'automation', visibility: 'public', import_url: 'https://github.com/BernardTsai/ao_automation.git')
project.save!
project.import_schedule!
project.import_start!
project.import_finish!

# Create 'Tools/environments' project
project = Project.new(creator: user, namespace_id: group.id, name:'environments', path:'environments', visibility: 'public', import_url: 'https://github.com/BernardTsai/ao_environments.git')
project.save!
project.import_schedule!
project.import_start!
project.import_finish!

# Create 'Applications' group
group = Group.new(name:'Applications', path: 'Applications', visibility: 'public')
group.save!

# Create 'Applications/example' project
project = Project.new(creator: user, namespace_id: group.id, name:'example', path:'example', visibility: 'public', import_url: 'https://github.com/BernardTsai/ao_example.git')
project.save!
project.import_schedule!
project.import_start!
project.import_finish!
EOF

# copy configuration to container
docker cp gitlab_configuration.rb gitlab:/gitlab_configuration.rb

# apply configuration script
docker exec gitlab gitlab-rails runner -e production /gitlab_configuration.rb 2> /dev/null

# cleanup
rm gitlab_configuration.rb

# Server configuration completed
echo Finished
