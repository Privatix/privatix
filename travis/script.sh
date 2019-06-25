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
    # download and unpack static artefacts
    powershell -Command 'mkdir c:\art'
    powershell -Command 'wget http://artdev.privatix.net/artefacts_win.zip -outFile c:\art\artefacts_win.zip'
    powershell -Command 'Expand-Archive -Path c:\art\artefacts_win.zip -DestinationPath c:\art'
    # download and install Bitrock installer
    powershell -Command 'mkdir c:\installbuilder'
    powershell -Command 'curl.exe -L "https://installbuilder.bitrock.com/installbuilder-enterprise-19.5.0-windows-x64-installer.exe" --output .\installbuilder-installer.exe'
    powershell -Command '.\installbuilder-installer.exe --mode unattended --prefix c:\installbuilder'
    # add license to Bitrock installer
    powershell -Command 'Copy-Item -Path "c:\Users\travis\gopath\src\github.com\Privatix\privatix\travis\encrypted\license.xml" -Destination "c:\installbuilder\"'
    
    powershell -Command "mkdir ${BUILD_WIN_DIR}"
    powershell -File 'build\win\publish-dapp.ps1' -wkdir "${BUILD_WIN_DIR}" -staticArtefactsDir "${ARTEFACTS_WIN_LOCATION}" -product vpn -installer -version ${VERSION_TO_SET_IN_BUILDER} -forceUpdate:${DAPP_INSTALLER_FORCE_UPDATE} -prodConfig -Verbose -dappguibranch "${GIT_BRANCH}" -dappctrlbranch "${GIT_BRANCH}" -dappinstbranch "${GIT_BRANCH}" -dappopenvpnbranch "${GIT_BRANCH}"
    #powershell -File 'build\win\publish-dapp.ps1' -wkdir "${BUILD_WIN_DIR}" -staticArtefactsDir "${ARTEFACTS_WIN_LOCATION}" -product proxy -installer -version ${VERSION_TO_SET_IN_BUILDER} -forceUpdate:${DAPP_INSTALLER_FORCE_UPDATE} -prodConfig -Verbose -dappguibranch "${GIT_BRANCH}" -dappctrlbranch "${GIT_BRANCH}" -dappinstbranch "${GIT_BRANCH}" -dappproxybranch "${GIT_BRANCH}"
fi