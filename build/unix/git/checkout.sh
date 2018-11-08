#!/usr/bin/env bash

cd `dirname $0`
. ../build.local.config

for repository in ${REPOSITORIES[@]}
do
    echo "${repository}"
    cd "${repository}"
    if [ "$(git branch --list "${GIT_BRANCH}")" ]
    then
        git checkout "${GIT_BRANCH}"
    else
        git checkout develop
    fi
    echo
done