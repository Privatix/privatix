#!/usr/bin/env bash

# get token: https://travis-ci.org/account/preferences

access_token=$1
build_scripts_branch=develop

request(){
    curl -s -X $1 \
       -H "Content-Type: application/json" \
       -H "Accept: application/json" \
       -H "Travis-API-Version: 3" \
       -H "Authorization: token $access_token" \
       $3 $4 \
       https://api.travis-ci.org/repo/privatix%2Fprivatix/$2
}

travis whoami


request POST env_vars -d '{ "env_var.name": "FOO", "env_var.value": "bar", "env_var.public": false }'

#body='{"request": {"branch":"'${build_scripts_branch}'"}}'

echo && echo vars:
request GET env_vars | grep -E 'name|id'

echo && echo Starting build on ${build_scripts_branch}...
#request POST requests -d '{"request": {"branch":"'${build_scripts_branch}'"}}'
#curl -s -X GET ${endpoint}/repo/privatix%2Fprivatix/env_vars



#echo Starting build on ${build_scripts_branch}...
#curl -s -X POST \
#   -H "Content-Type: application/json" \
#   -H "Accept: application/json" \
#   -H "Travis-API-Version: 3" \
#   -H "Authorization: token $access_token" \
#   -d "$body" \
#   https://api.travis-ci.org/repo/privatix%2Fprivatix/requests

#body='{
#  "request": {
#    "config": {
#      "merge_mode": deep_merge,
#      "env": {
#        "BAZ": "baz_from_api_request"
#      },
#      "script": "echo FOO"
#    }
#  }
#}'