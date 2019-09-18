#!/usr/bin/env bash

#
# ubuntu & osx
#
if [ "$TRAVIS_OS_NAME" = "linux" ] || [ "$TRAVIS_OS_NAME" = "osx" ]; then
    cd "${TRAVIS_BUILD_DIR}/build/unix" || exit 1
    . "./build.global.config"

    git/update.sh || exit 1

    build/dappctrl.sh || exit 1
    build/dapp-installer.sh || exit 1
    build/dapp-openvpn.sh || exit 1

    [ "$TRAVIS_OS_NAME" = "linux" ] && output_folder=${VPN_UBUNTU_OUTPUT_DIR}
    [ "$TRAVIS_OS_NAME" = "osx" ] && output_folder=${VPN_MAC_OUTPUT_DIR}

    mkdir -p "${output_folder}"

    cp -v   "${GOPATH}/bin/${DAPPCTRL}" \
            "${output_folder}/${DAPPCTRL}" || exit 1

    cp -v "${GOPATH}/bin/${DAPP_SUPERVISOR}" \
          "${output_folder}/${DAPP_SUPERVISOR}" || exit 1

    cp -v "${GOPATH}/bin/${DAPP_INSTALLER}" \
          "${output_folder}/${DAPP_INSTALLER}" || exit 1

    cp -v "${GOPATH}/bin/${DAPP_OPENVPN}" \
          "${output_folder}/${DAPP_OPENVPN}" || exit 1

    cp -v "${GOPATH}/bin/${OPENVPN_INST}" \
          "${output_folder}/${DAPP_INST}" || exit 1
fi

#
# windows
#
#if [ "$TRAVIS_OS_NAME" = "windows" ]; then
#    cd "${TRAVIS_BUILD_DIR}/build/win"
#    . "./build.win.global.config"
#
#    powershell -File '.\publish-dapp.ps1' -wkdir "${BUILD_WIN_DIR}" -staticArtefactsDir "${ARTEFACTS_WIN_LOCATION}" -product VPN -installer -version "${VERSION_TO_SET_IN_BUILDER}" -forceUpdate "${DAPP_INSTALLER_FORCE_UPDATE}" -dappctrlConf "${DAPPCTRL_CONFIG}" -guiEthNetwork "${DAPP_GUI_NETWORK}" -dappguibranch "${GIT_BRANCH}" -dappctrlbranch "${GIT_BRANCH}" -dappinstbranch "${GIT_BRANCH}" -dappopenvpnbranch "${GIT_BRANCH}" -defaultBranch "${GIT_BRANCH_DEFAULT}" -asjobs -Verbose
#fi