#!/usr/bin/env bash

. ${1}

build_dappctrl(){
    echo Start dappctrl build

    cd "${DAPP_CTRL_DIR}"

    "${DAPP_CTRL_DIR}"/scripts/build.sh
    "${DAPP_CTRL_DIR}"/scripts/create_database.sh
}

build_dapp_openvpn(){
    echo Start dapp-openvpn build
    cd "${DAPP_OPENVPN_DIR}"
}

build_dapp_gui(){
    echo Start dapp-gui build
    cd "${DAPP_GUI_DIR}"
}

build_dappctrl
build_dapp_openvpn
build_dapp_gui