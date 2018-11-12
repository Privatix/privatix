#!/usr/bin/env bash

cd `dirname $0`
./each_repo.sh "git checkout ${GIT_BRANCH}"
./each_repo.sh "git pull --all"
