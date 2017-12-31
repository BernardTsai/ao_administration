#!/usr/bin/env python

import os
import sys
import requests
import json
import yaml

# ----- VARIABLES --------------------------------------------------------------

url_prefix             = "http://192.168.178.59/api/v4/"
token                  = "CD4sS-Tn-UA39GWWb92A"

group_name             = "Tools"
group_description      = "Contains all tools"
project_name           = "LCM"
project_description    = "Lifecycle Management"

# ----- DEFINE VNF GROUP -------------------------------------------------------

print( "Defining group: {}".format(group_name))

url     = url_prefix + "groups/"
headers = {"Private-Token": token}

response = requests.get(url, headers=headers)

groups = response.json()

group_id = None
for group in groups:
    if group["name"] == group_name:
        group_id = group["id"]
        break

# create new group if needed
if group_id is None:
    url     = url_prefix + "groups"
    headers = {"Private-Token": token}
    data    = {
        "name":        group_name,
        "path":        group_name,
        "description": group_description,
        "visibility": "public"
    }

    response = requests.post(url, headers=headers, data=data)

    group_id = response.json()["id"]

# ----- CREATE PROJECT ---------------------------------------------------------

print( "Create Project: {}".format(project_name))

# try to find project
url     = url_prefix + "groups/{}/projects".format(group_id)
headers = {"Private-Token": token}

response = requests.get(url, headers=headers)

projects = response.json()

project_id = None
for project in projects:
    if project["name"] == project_name:
        project_id = project["id"]
        break

# create new project if needed
if project_id is None:
    url     = url_prefix + "projects"
    headers = {"Private-Token": token}
    data    = {
        "name":        project_name,
        "description": project_description,
        "visibility":  "public"
    }

    response = requests.post(url, headers=headers, data=data)

    project    = response.json()
    project_id = project["id"]

    # transfer project to group
    url     = url_prefix + "groups/{}/projects/{}".format(group_id, project_id)
    headers = {"Private-Token": token}
    data    = {
        "name":        project_name,
        "description": project_description,
        "visibility":  "public"
    }

    response = requests.post(url, headers=headers)

# ------------------------------------------------------------------------------

# ----- DEFINE VNF GROUP -------------------------------------------------------

print( "Defining group")

url     = url_prefix + "groups/"
headers = {"Private-Token": token}

response = requests.get(url, headers=headers)

groups = response.json()

group_id = None
for group in groups:
    if group["name"] == group_name:
        group_id = group["id"]
        break

# create new group if needed
if group_id is None:
    url     = url_prefix + "groups"
    headers = {"Private-Token": token}
    data    = {
        "name":        group_name,
        "path":        group_name,
        "description": group_description,
        "visibility": "public"
    }

    response = requests.post(url, headers=headers, data=data)

    group_id = response.json()["id"]

# ----- CREATE PROJECT ---------------------------------------------------------

print( "Create Project")

# try to find project
url     = url_prefix + "groups/{}/projects".format(group_id)
headers = {"Private-Token": token}

response = requests.get(url, headers=headers)

projects = response.json()

project_id = None
for project in projects:
    if project["name"] == project_name:
        project_id = project["id"]

        print( "Project has already been created:")
        print( project )
        break

# create new project if needed
if project_id is None:
    url     = url_prefix + "projects"
    headers = {"Private-Token": token}
    data    = {
        "name":        project_name,
        "description": project_description,
        "visibility":  "public"
    }

    response = requests.post(url, headers=headers, data=data)

    project    = response.json()
    project_id = project["id"]

    # transfer project to group
    url     = url_prefix + "groups/{}/projects/{}".format(group_id, project_id)
    headers = {"Private-Token": token}
    data    = {
        "name":        project_name,
        "description": project_description,
        "visibility":  "public"
    }

    response = requests.post(url, headers=headers)

    print( "New project:")
    print(project)

# ------------------------------------------------------------------------------
print( "Finished" )
