#!/usr/bin/env bash

. ${1}

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