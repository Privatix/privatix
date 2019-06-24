#!/usr/bin/env bash

# add variables to current process

destination="$(date +%Y_%m_%d)_build${TRAVIS_BUILD_NUMBER}"

deploy_file="${TRAVIS_BUILD_DIR}/travis/encrypted/deploy.txt"

host=$(cat "${deploy_file}" | head -1)
user=$(cat "${deploy_file}" | head -2 | tail -1)
pass=$(cat "${deploy_file}" | head -3 | tail -1)

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
    cd "${TRAVIS_BUILD_DIR}/build/unix"
    . "./build.global.config"

    (
    echo "
    cd travis
    mkdir ${destination}
    cd ${destination}
    mkdir $(basename "${VPN_UBUNTU_OUTPUT_DIR}")
    put -r ${VPN_UBUNTU_OUTPUT_DIR}
    ") | sftp -oStrictHostKeyChecking=no -i "${TRAVIS_BUILD_DIR}/travis/encrypted/travis.ed25519" ${user}@${host}
fi


#
# mac
#
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
    cd "${TRAVIS_BUILD_DIR}/build/unix"
    . "./build.global.config"
    
    (
    echo "
    cd travis
    mkdir ${destination}
    cd ${destination}
    mkdir $(basename "${VPN_MAC_OUTPUT_DIR}")
    put -r ${VPN_MAC_OUTPUT_DIR}
    mkdir $(basename "${PROXY_MAC_OUTPUT_DIR}")
    put -r ${PROXY_MAC_OUTPUT_DIR}
    ") | sftp -oStrictHostKeyChecking=no -i "${TRAVIS_BUILD_DIR}/travis/encrypted/travis.ed25519" ${user}@${host}
fi

if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    cd "${TRAVIS_BUILD_DIR}/build/win"
    . "./build.win.global.config"
    
    (
    . 
    echo "
    cd travis
    mkdir ${destination}
    cd ${destination}
    mkdir $(basename "${VPN_WIN_OUTPUT_DIR}")
    put -r ${VPN_WIN_INPUT_DIR}
    ") | sftp -oStrictHostKeyChecking=no -i "${TRAVIS_BUILD_DIR}/travis/encrypted/travis.ed25519" ${user}@${host}
fi