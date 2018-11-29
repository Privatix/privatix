#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
cd ..

. ./build.sealed.config

clear(){
    rm -rf ${PACKAGE_BIN}
    mkdir -p ${PACKAGE_BIN}
}

zip_package(){
    zip -r "${PACKAGE_BIN}/${APP_ZIP}" ${APPLICATION_BIN}
}

copy_installer(){
    cp -v ${DAPPINSTALLER_BIN}/${DAPP_INSTALLER} \
          ${PACKAGE_BIN}/${DAPP_INSTALLER}

    cp -v ${DAPPINSTALLER_BIN}/${DAPP_INSTALLER_CONFIG} \
          ${PACKAGE_BIN}/${DAPP_INSTALLER_CONFIG}
}

./git/update.sh

./build_installer.shs
./build_ctrl.sh
./build_openvpn.sh
./build_gui.sh

clear
zip_package
copy_installer