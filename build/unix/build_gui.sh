#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.sealed.config

echo
echo dapp-gui
echo

clean(){
    rm -rf ${DAPP_GUI_DIR}/build/
    rm -rf ${DAPP_GUI_BIN}

    mkdir -p ${DAPP_GUI_BIN}
}

build(){
    cd "${DAPP_GUI_DIR}"
    npm install
    npm run build
}

make_packages(){
    cd "${DAPP_GUI_DIR}"
    npm run package-mac
    npm run package-linux
    npm run package-win

    cd ${root_dir}
    rsync -avzh ${DAPP_GUI_DIR}/release-builds/. \
                ${DAPP_GUI_BIN}
}

clean
build

if [[ ${PACKAGE_GUI} = true ]]
then
    make_packages
fi