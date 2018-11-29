#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.sealed.config

echo
echo dappinstaller
echo

clean(){
    rm "${GOPATH}"/bin/${DAPP_INSTALLER}
    rm -rf ${DAPPINSTALLER_BIN}
    mkdir -p ${DAPPINSTALLER_BIN}
}

build(){
    export DAPPINST_DIR

    "${DAPPINST_DIR}"/scripts/build.sh

    cp -v   "${GOPATH}"/bin/${DAPP_INSTALLER} \
            ${DAPPINSTALLER_BIN}/${DAPP_INSTALLER}
}

copy_config(){
     cp -v   ${DAPPINST_DIR}/${DAPP_INSTALLER_CONFIG} \
             ${DAPPINSTALLER_BIN}/${DAPP_INSTALLER_CONFIG}
}


clean
build
copy_config