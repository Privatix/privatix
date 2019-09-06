# Getting started

## Steps

Steps of the program execution:

1. Merge environment variables:
     ```
     vars.json -> https://travis-ci.org/Privatix/privatix
     ```
1. Start travis build 
    * If `GIT_BRANCH` is presented in https://github.com/Privatix/privatix, then
start build on a `GIT_BRANCH` branch
    * Else start build on a `GIT_BRANCH_DEFAULT` branch

## Install requirements

```bash
pip install -r requirements.txt
```

## Get Token

There are two ways to get a token

1. Get the API token from your Travis CI [Profile page](https://travis-ci.org/account/preferences) 
1. Use the Travis CI command line client: 
    ```bash
    travis login --org
    travis token --org
    ```

## Usage

```
python ./start_travis_build.py <token> <path_to_vars.json>
```

## Example

```bash
python ./start_travis_build.py KJDSNKSJDKSNDKNS ./vars.json
```