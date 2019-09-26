#!/usr/bin/env bash

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
  echo Start running tests...
  ../tests/integrational/helpers/setenv.sh
  cd ../tests/integrational
  npm install
  npm run test
fi