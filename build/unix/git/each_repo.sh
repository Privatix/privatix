#!/usr/bin/env bash

cd `dirname $0`
. ../build.local.config

for ((i=0;i<${#REPOSITORIES[@]};++i));
do
    echo
    echo Repo: ${REPOSITORIES[i]}
    cd ${REPOSITORIES[i]}

    echo Command: $1
    $1
done