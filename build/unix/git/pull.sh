#!/usr/bin/env bash

cd `dirname $0`
. ../build.local.config

for repository in ${REPOSITORIES[@]}
do
    echo "${repository}"
    cd "${repository}"
    git pull --all
done
