#!/usr/bin/env bash

# common

# make build.local.config
cp ${TRAVIS_BUILD_DIR}/build/unix/build.config \
   ${TRAVIS_BUILD_DIR}/build/unix/build.local.config

# clone repositories
${TRAVIS_BUILD_DIR}/build/unix/git/clone.sh

# decrypt bitrock license
openssl aes-256-cbc \
    -K $encrypted_bd83225125eb_key \
    -iv $encrypted_bd83225125eb_iv \
    -in ${TRAVIS_BUILD_DIR}/build/license.xml.enc \
    -out ${TRAVIS_BUILD_DIR}/build/license.xml -d

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
    sudo apt-get update
fi