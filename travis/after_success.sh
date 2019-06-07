#!/usr/bin/env bash

# add variables to current process
cd "${TRAVIS_BUILD_DIR}/build/unix"
. "./build.global.config"

destination="$(date +%Y_%m_%d)_build${TRAVIS_BUILD_NUMBER}"

deploy_file="${TRAVIS_BUILD_DIR}/travis/encrypted/deploy.txt"

host=$(cat "${deploy_file}" | head -1)
user=$(cat "${deploy_file}" | head -2 | tail -1)
pass=$(cat "${deploy_file}" | head -3 | tail -1)

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then
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

