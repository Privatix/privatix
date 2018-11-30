#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)"
cd "${root_dir}"
cd ..

. ./build.sealed.config

cd "${root_dir}"
for repository in ${REPOSITORIES[@]}
do
    echo -----------------------------------------------------------------------
    echo "${repository}"
    cd "${repository}"
    if [[ "$(git branch --list "${GIT_BRANCH}")" ]]
    then
        git checkout "${GIT_BRANCH}"
    else
        git checkout develop
    fi
    echo
    echo
    git log  -1 --stat | tail
done