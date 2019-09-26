#!/usr/bin/env bash

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
  echo Start running tests...
  cd ../tests/integrational
  npm install
  npm run test
fi