#!/usr/bin/env bash

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
  echo Start running tests...
  ${TRAVIS_BUILD_DIR}/tests/integrational/helpers/setenv.sh || exit 1
  cd ${TRAVIS_BUILD_DIR}/tests/integrational || exit 1
  npm install || exit 1
  npm run test || exit 1
fi