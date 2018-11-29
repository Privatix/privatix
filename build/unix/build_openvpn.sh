#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.sealed.config

echo
echo dapp-openvpn
echo

clean(){
    rm "${GOPATH}"/bin/${DAPP_OPENVPN_INST}
    rm "${GOPATH}"/bin/${DAPP_OPENVPN}
    rm "${GOPATH}"/bin/${OPENVPN_INST}
}

build(){
    if [[ ! -d "${GOPATH}/bin/" ]]; then
        mkdir "${GOPATH}"/bin/
    fi

    export DAPP_OPENVPN_DIR

    "${DAPP_OPENVPN_DIR}"/scripts/build.sh
}

clean
build