#!/usr/bin/env bash

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
   ${TRAVIS_BUILD_DIR}/travis/atests/deploy.sh || exit 1
   ${TRAVIS_BUILD_DIR}/travis/atests/run_tests.sh || exit 1
fi