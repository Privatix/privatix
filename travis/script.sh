#!/usr/bin/env bash

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
    ${TRAVIS_BUILD_DIR}/build/unix/vpn_ubuntu.sh || exit 1
fi

#
# osx
#
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
    ${TRAVIS_BUILD_DIR}/build/unix/vpn_mac.sh || exit 1
    ${TRAVIS_BUILD_DIR}/build/unix/proxy_mac.sh || exit 1
fi