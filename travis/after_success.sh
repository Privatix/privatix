#!/usr/bin/env bash

# add variables to current process
cd "${TRAVIS_BUILD_DIR}/build/unix"
. "./build.global.config"

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
    cd "${VPN_UBUNTU_OUTPUT_DIR}" && ls -d $PWD/*
fi


#
# mac
#
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
    cd "${VPN_MAC_OUTPUT_DIR}" && ls -d $PWD/*
    cd "${PROXY_MAC_OUTPUT_DIR}" && ls -d $PWD/*
fi