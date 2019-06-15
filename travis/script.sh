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
    ${TRAVIS_BUILD_DIR}/build/unix/proxy_mac.sh --keep_common_binaries || exit 1
fi

#
# windows
#
if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    powershell -Command 'mkdir c:\art'
    powershell -Command 'wget http://artdev.privatix.net/artefacts_win.zip -outFile c:/art/artefacts_win.zip'
    powershell -Command 'Expand-Archive -Path c:\art\artefacts_win.zip -DestinationPath C:\art'
    powershell -Command '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; wget -URI https://installbuilder.bitrock.com/installbuilder-enterprise-19.5.0-windows-x64-installer.exe -OutFile .\installbuilder-installer.exe -UseBasicParsing'
    powershell -Command '.\installbuilder-installer.exe --mode unattended --prefix c:\installbuilder'
    #powershell -File 'build\win\prepare-environment-travis.ps1'
    cp "${TRAVIS_BUILD_DIR}/travis/encrypted/license.xml" \
       "/mnt/c/installbuilder/license.xml" || exit 1
fi