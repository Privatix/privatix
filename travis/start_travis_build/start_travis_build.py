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


def _check_ok(text, response):
    print(text)
    if not response.ok:
        print("\tError: {0}({1})".format(response.text, response.reason))
        exit(1)
    print('\tOk: ' + str(response))


def travis_get_env_vars():
    response = requests.get(endpoint + "/env_vars", headers=header)
    _check_ok("Get env_vars:", response)
    for entity in response.json()['env_vars']:
        if 'value' in entity:
            yield (entity['name'], (entity['id'], entity['value']))


def json_get_vars(path):
    with open(path) as f:
        return json.load(f)


def travis_add_env_var(name, value):
    env_var = {
        'env_var.name': name,
        'env_var.value': value,
        'env_var.public': True,
    }

    response = requests.post(endpoint + "/env_vars", json=env_var, headers=header)
    _check_ok("Add {0}: {1}".format(name, value), response)


def travis_update_env_var(name, var_id, value):
    env_var = {
        'env_var.value': value,
    }

    response = requests.patch(endpoint + "/env_var/" + var_id, json=env_var, headers=header)
    _check_ok("Update {0}: {1}".format(name, value), response)


def travis_start_build(branch):
    request = {
        'request': {
            'branch': branch
        }}

    response = requests.post(endpoint + "/requests", json=request, headers=header)
    _check_ok("\n\nStart build on {0}".format(branch), response)

    j = response.json()
    print(
        "\nBuild info:"
        "\n\ttype:   {0}".format(j["@type"]) +
        "\n\tbranch: {0}".format(j["request"]["branch"]) +
        "\n\tlink:   {0}/{1}".format("https://travis-ci.org", j["repository"]["slug"])
    )


def merge_env_vars(vars_from_file, vars_from_travis):
    for json_var in vars_from_file:
        new_value = vars_from_file[json_var]

        if json_var not in vars_from_travis:
            travis_add_env_var(json_var, new_value)
            continue

        if new_value == vars_from_travis[json_var][1]:
            continue

        travis_update_env_var(name=json_var, var_id=vars_from_travis[json_var][0], value=new_value)


def travis_get_branches():
    response = requests.get(endpoint + "/branches", headers=header)
    _check_ok("Get branches:", response)
    return response.json()


print("\n\nMerge environment variables:\n")

merge_env_vars(
    json_get_vars(json_vars_path),
    dict(travis_get_env_vars())
)

env_vars = dict(travis_get_env_vars())
print('\n\nActual env_vars:\n')
for v in env_vars:
    print("\t{0}: {1}".format(v, env_vars[v][1]))

print('\n')
branches = travis_get_branches()
branches_names = set(map(lambda branch: branch['name'], branches['branches']))
if env_vars['GIT_BRANCH'][1] in branches_names:
    travis_start_build(env_vars['GIT_BRANCH'][1])
else:
    travis_start_build(env_vars['GIT_BRANCH_DEFAULT'][1])
