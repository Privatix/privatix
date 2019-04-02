#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.sealed.config

echo -----------------------------------------------------------------------
echo dappinstaller
echo -----------------------------------------------------------------------

clean(){
    rm -rf ${DAPPINSTALLER_BIN}
    mkdir -p ${DAPPINSTALLER_BIN} || exit 1
}

build(){
    if [[ ! -d "${GOPATH}/bin/" ]]; then
        mkdir "${GOPATH}"/bin/ || exit 1
    fi

    cd "${DAPPINST_DIR}" || exit 1

    ./scripts/build.sh || exit 1

    cd ${root_dir}
    cp -v   "${GOPATH}"/bin/${DAPP_INSTALLER} \
            ${DAPPINSTALLER_BIN}/${DAPP_INSTALLER} || exit 1
}

copy_config(){
     cp -v   ${DAPPINST_DIR}/${DAPP_INSTALLER_CONFIG} \
             ${DAPPINSTALLER_BIN}/${DAPP_INSTALLER_CONFIG} || exit 1
}


clean
build
copy_config