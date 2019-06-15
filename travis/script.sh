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
    powershell -Command 'curl.exe -L "https://installbuilder.bitrock.com/installbuilder-enterprise-19.5.0-windows-x64-installer.exe" --output .\installbuilder-installer.exe'
    powershell -Command 'mkdir c:\installbuilder'
    powershell -Command '.\installbuilder-installer.exe --mode unattended --prefix c:\installbuilder'
    powershell -Command 'ls c:\installbuilder'
    powershell -Command 'Copy-Item -Path "c:\Users\travis\gopath\src\github.com\Privatix\privatix\travis\encrypted\license.xml" -Destination "c:\installbuilder\"'
    powershell -File 'build\win\publish-dapp.ps1' -staticArtefactsDir 'C:\art\' -product vpn -gitpull -installer -version "0.23.2" -prodConfig -Verbose
fi