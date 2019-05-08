#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)"
cd "${root_dir}"
cd ..

. ./build.global.config

cd "${root_dir}"
for ((i=0;i<${#REPOSITORIES[@]};++i));
do
    git clone "${GIT_URLS[i]}" "${REPOSITORIES[i]}"
done

