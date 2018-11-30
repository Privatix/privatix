#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)"
cd "${root_dir}"
cd ..

. ./build.sealed.config

cd "${root_dir}"
for ((i=0;i<${#REPOSITORIES[@]};++i));
do
    echo
    echo Repo: ${REPOSITORIES[i]}
    cd "${REPOSITORIES[i]}"

    echo Command: $1
    "$1"
done