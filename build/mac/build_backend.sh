#!/usr/bin/env bash

. ${1}

build_dappctrl(){
    echo Start dappctrl build

    cd "${DAPP_CTRL_DIR}"

    "${DAPPCTRL_DIR}"/scripts/build.sh
    "${DAPPCTRL_DIR}"/scripts/create_database.sh
}

build_dapp_openvpn(){
    echo Start dapp-openvpn build
    cd "${DAPP_OPENVPN_DIR}"
}

build_dappctrl
build_dapp_openvpn