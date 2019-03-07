#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.sealed.config

echo -----------------------------------------------------------------------
echo dapp-openvpn
echo -----------------------------------------------------------------------

clean(){
    echo
}

build(){
    if [[ ! -d "${GOPATH}/bin/" ]]; then
        mkdir "${GOPATH}"/bin/ || exit 1
    fi

    export DAPP_OPENVPN_DIR

    "${DAPP_OPENVPN_DIR}/scripts/toml.sh" \
       "${DAPP_OPENVPN_DIR}/Gopkg.toml.template" > \
       "${DAPP_OPENVPN_DIR}/Gopkg.toml" || exit 1

    "${DAPP_OPENVPN_DIR}"/scripts/build.sh || exit 1
}

clean
build