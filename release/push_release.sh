#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./release.local.config

for repository in ${REPOSITORIES[@]}
do
    cd ${repository}
    if [ "$(git branch --list release/${RELEASE_VERSION})" ]
    then
        printf "\n%s\n" ${repository}
        git checkout release/${RELEASE_VERSION}
        git push origin HEAD
    fi
done