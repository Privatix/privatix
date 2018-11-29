#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)/..
cd ${root_dir}

. ./build.sealed.config

tmp_dir=${PACKAGE_BIN}/tmp

clear(){
    rm -rf ${PACKAGE_BIN}

    mkdir -p ${PACKAGE_BIN}
    mkdir -p ${tmp_dir}/${DAPPCTRL}
    mkdir -p ${tmp_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}
}

zip_package(){
    zip -r "${PACKAGE_BIN}/${APP_ZIP}" ${APPLICATION_BIN}
}

copy_ctrl(){
    cp -v   ${DAPPCTRL_BIN}/${DAPPCTRL} \
            ${tmp_dir}/${DAPPCTRL}/${DAPPCTRL}
    cp -v   ${DAPPCTRL_BIN}/${DAPPCTRL_CONFIG} \
            ${tmp_dir}/${DAPPCTRL}/${DAPPCTRL_CONFIG}
}

create_gui_package(){
    cd "${DAPP_GUI_DIR}"
    npm i && npm run package-mac

    echo
    echo copy ${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}
    echo

    cd ${root_dir}
    pwd
    rsync -azhP ${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}/. \
                ${tmp_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}

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
copy_ctrl
create_gui_package

zip_package
copy_installer
