#!/usr/bin/env bash

. ${1}

for repository in ${ALL_REPOSITORIES[@]}
do
    cd ${repository}
    if [ "$(git branch --list ${GIT_BRANCH})" ]
    then
        git checkout ${GIT_BRANCH}
    else
        git checkout develop
    fi
done