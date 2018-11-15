#!/usr/bin/env bash

cd `dirname $0`
. ../build.local.config

for ((i=0;i<${#REPOSITORIES[@]};++i));
do
    git clone "${GIT_URLS[i]}" "${REPOSITORIES[i]}"
    echo
done

