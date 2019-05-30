# Getting started

## Steps

1. Merge `vars.json` and https://travis-ci.org/Privatix/privatix 
environment variables
1. Start build on a develop branch

## Install requirements

```bash
pip install -r requirements.txt
```

## Usage

```
python ./start_travis_build.py <token> <path_to_vars.json>
```

## Example

```bash
python ./start_travis_build.py KJDSNKSJDKSNDKNS ./vars.json
```