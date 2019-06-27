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
    cd "${TRAVIS_BUILD_DIR}/build/win"
    . "./build.win.global.config"
        
    
    echo powershell -File '.\publish-dapp.ps1' -wkdir "${BUILD_WIN_DIR}" -staticArtefactsDir "${ARTEFACTS_WIN_LOCATION}" -product vpn -installer -version "${VERSION_TO_SET_IN_BUILDER}" -forceUpdate "${DAPP_INSTALLER_FORCE_UPDATE}" -dappctrlConf "${DAPPCTRL_CONFIG}" -dappguibranch "${GIT_BRANCH}" -dappctrlbranch "${GIT_BRANCH}" -dappinstbranch "${GIT_BRANCH}" -dappopenvpnbranch "${GIT_BRANCH}" -Verbose
    echo powershell -File '.\publish-dapp.ps1' -wkdir "${BUILD_WIN_DIR}" -staticArtefactsDir "${ARTEFACTS_WIN_LOCATION}" -product vpn -installer -version ${VERSION_TO_SET_IN_BUILDER} -forceUpdate ${DAPP_INSTALLER_FORCE_UPDATE} -dappctrlConf "${DAPPCTRL_CONFIG}" -dappguibranch "${GIT_BRANCH}" -dappctrlbranch "${GIT_BRANCH}" -dappinstbranch "${GIT_BRANCH}" -dappopenvpnbranch "${GIT_BRANCH}" -Verbose
    powershell -File '.\publish-dapp.ps1' -wkdir "${BUILD_WIN_DIR}" -staticArtefactsDir "${ARTEFACTS_WIN_LOCATION}" -product vpn -installer -version ${VERSION_TO_SET_IN_BUILDER} -forceUpdate ${DAPP_INSTALLER_FORCE_UPDATE} -dappctrlConf "${DAPPCTRL_CONFIG}" -dappguibranch "${GIT_BRANCH}" -dappctrlbranch "${GIT_BRANCH}" -dappinstbranch "${GIT_BRANCH}" -dappopenvpnbranch "${GIT_BRANCH}" -Verbose
fi