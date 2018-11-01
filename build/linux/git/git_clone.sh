#!/usr/bin/env bash

. ${1}

for ((i=0;i<${#REPOSITORIES[@]};++i));
do
    git clone "${GIT_URLS[i]}" "${REPOSITORIES[i]}"
    echo
done

