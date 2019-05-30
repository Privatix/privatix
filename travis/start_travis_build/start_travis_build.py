# pip install requests
import json
import sys

import requests

token = sys.argv[1]
json_vars_path = sys.argv[2]

header = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Travis-API-Version': '3',
    'Authorization': 'token ' + token,
}
endpoint = "https://api.travis-ci.org/repo/privatix%2Fprivatix"
privatix_repo_branch = "develop"


def check_ok(text, response):
    print(text)
    if not response.ok:
        print("\tError: {0}({1})".format(response.text, response.reason))
        exit(1)
    print('\tOk: ' + str(response))


def get_env_vars():
    env_vars_response = requests.get(endpoint + "/env_vars", headers=header)
    check_ok("Get env_vars:", env_vars_response)
    for entity in env_vars_response.json()['env_vars']:
        if 'value' in entity:
            yield (entity['name'], (entity['id'], entity['value']))


def get_json_vars(path):
    with open(path) as f:
        return json.load(f)


def add_env_var(name, value):
    env_var = {
        'env_var.name': name,
        'env_var.value': value,
        'env_var.public': True,
    }

    response = requests.post(endpoint + "/env_vars", json=env_var, headers=header)
    check_ok("Add {0}: {1}".format(name, value), response)


def update_env_var(name, var_id, value):
    env_var = {
        'env_var.value': value,
    }

    response = requests.patch(endpoint + "/env_var/" + var_id, json=env_var, headers=header)
    check_ok("Update {0}: {1}".format(name, value), response)


def start_build(branch):
    request = {
        'request': {
            'branch': branch
        }}

    response = requests.post(endpoint + "/requests", json=request, headers=header)
    check_ok("\n\nStart build on {0}".format(branch), response)

    j = response.json()
    print(
        "\nBuild info:"
        "\n\ttype:   {0}".format(j["@type"]) +
        "\n\tbranch: {0}".format(j["request"]["branch"]) +
        "\n\tlink:   {0}/{1}".format("https://travis-ci.org", j["repository"]["slug"])
    )


json_vars = get_json_vars(json_vars_path)
env_vars = dict(get_env_vars())

print("\n\nSet environment variables:")
for json_var in json_vars:
    new_value = json_vars[json_var]

    if json_var not in env_vars:
        add_env_var(json_var, new_value)
        continue

    if new_value == env_vars[json_var][1]:
        continue

    update_env_var(name=json_var, var_id=env_vars[json_var][0], value=new_value)

print("\n")
env_vars = dict(get_env_vars())

print('\n\nActual env_vars:')
for v in env_vars:
    print("\t{0}: {1}".format(v, env_vars[v][1]))

start_build(privatix_repo_branch)
