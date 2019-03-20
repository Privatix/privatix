#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.sealed.config

echo -----------------------------------------------------------------------
echo dappctrl
echo -----------------------------------------------------------------------

clean(){
    rm -rf ${DAPPCTRL_BIN}
    mkdir -p ${DAPPCTRL_BIN} || exit 1
    mkdir -p ${DAPPCTRL_LOG} || exit 1
}

build(){
    if [[ ! -d "${GOPATH}/bin/" ]]; then
        mkdir "${GOPATH}"/bin/ || exit 1
    fi

    export DAPPCTRL_DIR

    "${DAPPCTRL_DIR}"/scripts/build.sh || exit 1

    cp -v   "${GOPATH}"/bin/${DAPPCTRL} \
            ${DAPPCTRL_BIN}/${DAPPCTRL} || exit 1
}

copy_inst_config(){
    cp -v   "${DAPPCTRL_DIR}"/${DAPPCTRL_CONFIG} \
            ${DAPPCTRL_BIN}/${DAPPCTRL_FOR_INSTALLER_CONFIG} || exit 1
}


clean
build
copy_inst_config

