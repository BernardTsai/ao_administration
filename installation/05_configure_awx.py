#!/usr/bin/env python

import os
import sys
import requests
import json
import yaml

# ----- VARIABLES --------------------------------------------------------------

url_prefix     = "http://localhost/api/v2/"
username       = "admin"
password       = "password"
organization   = "DTAG"
project        = "LCM"
project_url    = "https://github.com/BernardTsai/lcm.git"
inventory      = "CLOUD"
inventory_file = "./inventory.yaml"

# ----- GET TOKEN --------------------------------------------------------------

print( "Authenticating")

url      = url_prefix + "authtoken/"
headers  = {"Content-Type": "application/json"}
data     = json.dumps( {"username":username, "password":password} )

response = requests.post(url, headers=headers, data=data)

token    = response.json()['token']

# ----- DEFINE ORGANIZATION ----------------------------------------------------

print( "Defining organization")

url      = url_prefix + "organizations/?name={}".format(organization)
headers  = {"Authorization": "Token {}".format(token)}

response = requests.get(url, headers=headers)

# organization was found
if response.json()['count'] != 0:
    organization_id = response.json()['results'][0]['id']
# not found: create new organization
else:
    url     = url_prefix + "organizations/"
    headers = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
    data    = json.dumps( {"name":organization} )

    response = requests.post(url, headers=headers, data=data)

    organization_id = response.json()['id']

# ----- DEFINE PROJECT ---------------------------------------------------------

print( "Defining project")

url      = url_prefix + "projects/?name={}".format(project)
headers  = {"Authorization": "Token {}".format(token)}

response = requests.get(url, headers=headers)

# project was found
if response.json()['count'] != 0:
    project_id = response.json()['results'][0]['id']
# not found: create new project
else:
    url     = url_prefix + "projects/"
    headers = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
    data    = json.dumps( {"organization":organization_id, "name":project, "scm_type":"git", "scm_url":project_url} )

    response = requests.post(url, headers=headers, data=data)

    project_id = response.json()['id']

# ----- DEFINE INVENTORY -------------------------------------------------------

print( "Defining inventory")

url      = url_prefix + "inventories/?name={}".format(inventory)
headers  = {"Authorization": "Token {}".format(token)}

response = requests.get(url, headers=headers)

# inventory was found: update inventory
if response.json()['count'] != 0:
    inventory_id = response.json()['results'][0]['id']

    # load inventory file
    path = os.path.abspath(os.path.dirname(__file__))
    path = os.path.join(path, inventory_file)
    with open(path) as file:
        yaml_string = file.read()
    inventory_object = yaml.load(yaml_string)
    inventory_data   = json.dumps(inventory_object)

    # update existing inventory
    url     = url_prefix + "inventories/{}/variable_data/".format(inventory_id)
    headers = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
    data    = inventory_data

    response = requests.put(url, headers=headers, data=data)

# not found: create new inventory
else:
    # load inventory file
    path = os.path.abspath(os.path.dirname(__file__))
    path = os.path.join(path, inventory_file)
    with open(path) as file:
        yaml_string = file.read()
    inventory_object = yaml.load(yaml_string)
    inventory_data   = json.dumps(inventory_object)

    # create new inventory
    url     = url_prefix + "inventories/"
    headers = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
    data    = json.dumps( {"name":inventory, "organization":organization_id, "variables":inventory_data} )

    response = requests.post(url, headers=headers, data=data)

    inventory_id = response.json()['id']

# ----- DEFINE DEPLOYMENT JOB TEMPLATE -----------------------------------------

print( "Defining deployment job template")

url      = url_prefix + "job_templates/?name=Deployment"
headers  = {"Authorization": "Token {}".format(token)}

response = requests.get(url, headers=headers)

# job template was found
if response.json()['count'] != 0:
    deployment_template_id = response.json()['results'][0]['id']
# not found: create new job template
else:
    url     = url_prefix + "job_templates/"
    headers = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
    data    = json.dumps( {"name":"Deployment", "organization":organization_id, "inventory":inventory_id, "project":project_id, "playbook":"deployment-playbook.yml", "ask_variables_on_launch": True} )

    response = requests.post(url, headers=headers, data=data)

    deployment_template_id = response.json()['id']

# ----- DEFINE INVENTORY JOB TEMPLATE ------------------------------------------

print( "Defining inventory job template")

url      = url_prefix + "job_templates/?name=Inventory"
headers  = {"Authorization": "Token {}".format(token)}

response = requests.get(url, headers=headers)

# job template was found
if response.json()['count'] != 0:
    inventory_template_id = response.json()['results'][0]['id']
# not found: create new job template
else:
    url     = url_prefix + "job_templates/"
    headers = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
    data    = json.dumps( {"name":"Inventory", "organization":organization_id, "inventory":inventory_id, "project":project_id, "playbook":"inventory-playbook.yml", "ask_variables_on_launch": True} )

    response = requests.post(url, headers=headers, data=data)

    inventory_template_id = response.json()['id']

# ----- DEFINE SCALE-IN JOB TEMPLATE -------------------------------------------

print( "Defining scale-in job template")

url      = url_prefix + "job_templates/?name=Scale-In"
headers  = {"Authorization": "Token {}".format(token)}

response = requests.get(url, headers=headers)

# job template was found
if response.json()['count'] != 0:
    scale_in_template_id = response.json()['results'][0]['id']
# not found: create new job template
else:
    url     = url_prefix + "job_templates/"
    headers = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
    data    = json.dumps( {"name":"Scale-In", "organization":organization_id, "inventory":inventory_id, "project":project_id, "playbook":"scale-in-playbook.yml", "ask_variables_on_launch": True} )

    response = requests.post(url, headers=headers, data=data)

    scale_in_template_id = response.json()['id']

# ----- DEFINE SCALE-OUT JOB TEMPLATE ------------------------------------------

print( "Defining scale-out job template")

url      = url_prefix + "job_templates/?name=Scale-Out"
headers  = {"Authorization": "Token {}".format(token)}

response = requests.get(url, headers=headers)

# job template was found
if response.json()['count'] != 0:
    scale_out_template_id = response.json()['results'][0]['id']
# not found: create new job template
else:
    url     = url_prefix + "job_templates/"
    headers = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
    data    = json.dumps( {"name":"Scale-Out", "organization":organization_id, "inventory":inventory_id, "project":project_id, "playbook":"scale-out-playbook.yml", "ask_variables_on_launch": True} )

    response = requests.post(url, headers=headers, data=data)

    scale_out_template_id = response.json()['id']

# ----- DEFINE CLEANUP JOB TEMPLATE --------------------------------------------

print( "Defining cleanup job template")

url      = url_prefix + "job_templates/?name=Cleanup"
headers  = {"Authorization": "Token {}".format(token)}

response = requests.get(url, headers=headers)

# job template was found
if response.json()['count'] != 0:
    cleanup_template_id = response.json()['results'][0]['id']
# not found: create new job template
else:
    url     = url_prefix + "job_templates/"
    headers = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
    data    = json.dumps( {"name":"Cleanup", "organization":organization_id, "inventory":inventory_id, "project":project_id, "playbook":"cleanup-playbook.yml", "ask_variables_on_launch": True} )

    response = requests.post(url, headers=headers, data=data)

    cleanup_template_id = response.json()['id']

# ------------------------------------------------------------------------------

print( "Finished" )
