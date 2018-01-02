#!/usr/bin/env python

import os
import sys
import requests
import json

# ----- VARIABLES --------------------------------------------------------------

url_prefix     = "http://localhost:81/api/v2/"
username       = "admin"
password       = "password"

# ----- GET TOKEN --------------------------------------------------------------

print( "Authenticating")

url      = url_prefix + "authtoken/"
headers  = {"Content-Type": "application/json"}
data     = json.dumps( {"username":username, "password":password} )

response = requests.post(url, headers=headers, data=data)

token    = response.json()['token']


# ----- GET Template ----------------------------------------------------------

print( "Get template")

url      = url_prefix + "job_templates/?name={}".format("Inventory")
headers  = {"Authorization": "Token {}".format(token)}

response = requests.get(url, headers=headers)

if response.json()['count'] == 0:
    print( "Template has not been defined")
    sys.exit(1)
else:
    template_id = response.json()['results'][0]['id']

# ----- CREATE JOB -------------------------------------------------------------

print( "Inventory of VNF")

url        = url_prefix + "job_templates/{}/launch/".format(template_id)
headers    = {"Authorization": "Token {}".format(token), "Content-Type": "application/json"}
extra_vars = json.dumps( {"vnf":"Clearwater"} )
data       = json.dumps( {"extra_vars":extra_vars} )

response = requests.post(url, headers=headers, data=data)
print( response.text)
job_id = response.json()['id']

print("Job-ID: {}".format(job_id))

# ------------------------------------------------------------------------------

print( "Finished" )
