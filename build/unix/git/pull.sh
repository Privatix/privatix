#!/usr/bin/env bash

cd `dirname $0`
. ../build.local.config

./each_repo.sh "git checkout ${GIT_BRANCH}"
./each_repo.sh "git pull --all"
