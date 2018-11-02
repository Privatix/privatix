#!/usr/bin/env bash

. ${1}
export POSTGRES_PORT

build_dappctrl(){
    echo Start dappctrl build

    cd "${DAPP_CTRL_DIR}"

    "${DAPPCTRL_DIR}"/scripts/build.sh
    "${DAPPCTRL_DIR}"/scripts/create_database.sh
}

build_dapp_openvpn(){
    echo Start dapp-openvpn build

    cd "${DAPP_OPENVPN_DIR}"

    "${DAPP_OPENVPN_DIR}"/scripts/install.sh
    "${DAPP_OPENVPN_DIR}"/scripts/run_installer.sh
}

build_dappctrl
build_dapp_openvpn
