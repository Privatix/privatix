#!/usr/bin/env bash

# common

# make build.local.config
cp ${TRAVIS_BUILD_DIR}/build/unix/build.config \
   ${TRAVIS_BUILD_DIR}/build/unix/build.local.config

# clone repositories
${TRAVIS_BUILD_DIR}/build/unix/git/clone.sh

openssl aes-256-cbc -K $encrypted_b3625d5d910f_key -iv $encrypted_b3625d5d910f_iv \
    -in ${TRAVIS_BUILD_DIR}/travis/encrypted.zip.enc \
    -out ${TRAVIS_BUILD_DIR}/travis/encrypted.zip -d

unzip ${TRAVIS_BUILD_DIR}/travis/encrypted.zip \
      -d ${TRAVIS_BUILD_DIR}/travis/

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
    sudo apt-get update
fi

#
# windows
#
if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    powershell -Command "Set-ExecutionPolicy Bypass"
fi