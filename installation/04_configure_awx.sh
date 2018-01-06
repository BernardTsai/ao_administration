#!/bin/bash

# ------------------------------------------------------------------------------

echo Authenticating

export HEADER1="Content-Type: application/json"
export DATA='{"username":"admin", "password":"password"}'
export TOKEN=$(curl -s -d "$DATA" -H "$HEADER1" http://localhost:81/api/v2/authtoken/ | jq -r ".token")

echo $TOKEN

# ------------------------------------------------------------------------------

echo Defining organization

export HEADER1="Content-Type: application/json"
export HEADER2="Authorization: Token $TOKEN"
export DATA='{"name": "DTAG"}'
export ORGANIZATION=$(curl -s -d "$DATA" -H "$HEADER1" -H "$HEADER2" http://localhost:81/api/v2/organizations/ | jq -r ".id")

echo $ORGANIZATION

# ------------------------------------------------------------------------------

echo Defining project

export HEADER1="Content-Type: application/json"
export HEADER2="Authorization: Token $TOKEN"
export DATA='{"organization":'$ORGANIZATION', "name":"automation", "scm_type":"git", "scm_url":"http://gitlab/Tools/automation.git"}'
export PROJECT=$(curl -s -d "$DATA" -H "$HEADER1" -H "$HEADER2" http://localhost:81/api/v2/projects/ | jq -r ".id")

echo $PROJECT

sleep 5

# ------------------------------------------------------------------------------

echo Defining inventory

export INVENTORY_YAML=$(curl -s http://localhost/Tools/environments/raw/master/cloud.yaml)

export INVENTORY_JSON=$(echo "$INVENTORY_YAML" | python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=2)')
export INVENTORY_DATA=$(echo "$INVENTORY_JSON" | tr -d '\r\n' )
export INVENTORY_STRING=$(echo "$INVENTORY_DATA" | sed 's/\"/\\"/g' )
export HEADER1="Content-Type: application/json"
export HEADER2="Authorization: Token $TOKEN"
export DATA='{"name":"inventory", "organization":'$ORGANIZATION', "variables":"'$INVENTORY_STRING'"}'
export INVENTORY=$(curl -s -d "$DATA" -H "$HEADER1" -H "$HEADER2" http://localhost:81/api/v2/inventories/ | jq -r ".id")

echo $INVENTORY

# ------------------------------------------------------------------------------

echo Defining job templates

export HEADER1="Content-Type: application/json"
export HEADER2="Authorization: Token $TOKEN"

export DATA='{"name":"Deployment", "organization":'$ORGANIZATION', "inventory":'$INVENTORY', "project":'$PROJECT', "playbook":"deployment-playbook.yml", "ask_variables_on_launch": true, "verbosity": 3}'
export TEMPLATE=$(curl -s -d "$DATA" -H "$HEADER1" -H "$HEADER2" http://localhost:81/api/v2/job_templates/ | jq -r ".id")

echo $TEMPLATE

export DATA='{"name":"Inventory", "organization":'$ORGANIZATION', "inventory":'$INVENTORY', "project":'$PROJECT', "playbook":"inventory-playbook.yml", "ask_variables_on_launch": true, "verbosity": 3}'
export TEMPLATE=$(curl -s -d "$DATA" -H "$HEADER1" -H "$HEADER2" http://localhost:81/api/v2/job_templates/ | jq -r ".id")

echo $TEMPLATE

export DATA='{"name":"Scale-In", "organization":'$ORGANIZATION', "inventory":'$INVENTORY', "project":'$PROJECT', "playbook":"scale-in-playbook.yml", "ask_variables_on_launch": true, "verbosity": 3}'
export TEMPLATE=$(curl -s -d "$DATA" -H "$HEADER1" -H "$HEADER2" http://localhost:81/api/v2/job_templates/ | jq -r ".id")

echo $TEMPLATE

export DATA='{"name":"Scale-Out", "organization":'$ORGANIZATION', "inventory":'$INVENTORY', "project":'$PROJECT', "playbook":"scale-out-playbook.yml", "ask_variables_on_launch": true, "verbosity": 3}'
export TEMPLATE=$(curl -s -d "$DATA" -H "$HEADER1" -H "$HEADER2" http://localhost:81/api/v2/job_templates/ | jq -r ".id")

echo $TEMPLATE

export DATA='{"name":"Cleanup", "organization":'$ORGANIZATION', "inventory":'$INVENTORY', "project":'$PROJECT', "playbook":"cleanup-playbook.yml", "ask_variables_on_launch": true, "verbosity": 3}'
export TEMPLATE=$(curl -s -d "$DATA" -H "$HEADER1" -H "$HEADER2" http://localhost:81/api/v2/job_templates/ | jq -r ".id")

echo $TEMPLATE

# ------------------------------------------------------------------------------

echo Finished
