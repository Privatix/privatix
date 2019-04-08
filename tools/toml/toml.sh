#!/usr/bin/env bash

# rules:
#
#   develop         ->  develop
#   master          ->  master
#   feature/name    ->  develop
#   release/name    ->  release/name
#   hotfix/name     ->  master

if [[ "$#" -ne 1 ]];
then
    echo usage: toml.sh template_file_name
    exit 1
fi

#
#
#

# get current branch name
branch_name=$(git rev-parse --abbrev-ref HEAD ) || exit 1

# set replacement by default
replacement=${branch_name//\//\\/}

# if starts with "feature", then replacement=develop
if [[ ${branch_name} == feature* ]] ;
then
    replacement="develop"
fi

# if starts with "hotfix", then replacement=master
if [[ ${branch_name} == hotfix* ]] ;
then
    replacement="master"
fi

# replace "%BRANCH_NAME%" by replacement in the given file
sed 's/%BRANCH_NAME%/'${replacement}'/g' "$1" || exit 1
