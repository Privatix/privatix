#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
cd ..

. ./build.sealed.config

cd ${root_dir}
./each_repo.sh "git checkout ${GIT_BRANCH}"
./each_repo.sh "git pull --all"
