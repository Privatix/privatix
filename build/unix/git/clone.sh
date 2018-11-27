#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
cd ..

. ./build.sealed.config

cd ${root_dir}
for ((i=0;i<${#REPOSITORIES[@]};++i));
do
    git clone "${GIT_URLS[i]}" "${REPOSITORIES[i]}"
    echo
done

