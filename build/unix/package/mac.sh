#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd "${root_dir}"

. ./build.sealed.config

app_dir="${PACKAGE_BIN}/${APP}"

clear(){
    rm -rf "${PACKAGE_INSTALL_BUILDER_BIN}"
    rm -rf "${ARTEFACTS_BIN}"

    mkdir -p "${PACKAGE_BIN}"
    mkdir -p "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}"

    mkdir -p "${app_dir}/${DAPPCTRL}"
    mkdir -p "${app_dir}/${LOG}"
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}"
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}"
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_DATA}"
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${LOG}"
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}"
    mkdir -p "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}"
}

remove_app(){
    rm -rf "${app_dir}"
}

zip_package(){
    cd "${PACKAGE_BIN}"
    zip -r "${APP_ZIP}" \
           "${APP}"

    cd "${root_dir}"
}

copy_ctrl(){
    cp -v   "${DAPPCTRL_BIN}/${DAPPCTRL}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL}"
    cp -v   "${DAPPCTRL_BIN}/${DAPPCTRL_CONFIG}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL_CONFIG}"
}

create_gui_package(){
    cd "${DAPP_GUI_DIR}"
    npm i && npm run package-mac

    echo
    echo copy ${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}
    echo

    cd ${root_dir}
    pwd
    rsync -azhP "${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}/." \
                "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}"

}

copy_product(){
    # binaries
    cp -v "${GOPATH}/bin/${DAPP_OPENVPN}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${DAPP_OPENVPN}"

    cp -v "${GOPATH}/bin/${OPENVPN_INST}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${DAPP_INST}"

    #configs
    for config in ${CONFIGS_TO_COPY[@]}
    do
          cp -v "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_INST_PROJECT}/${config}" \
                "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}/${config}"
    done

    # templates
    cp -va "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_TEMPLATES_LOCATION}/" \
           "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}"

    mv "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${DAPP_VPN_AGENT_CONFIG}" \
       "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${ADAPTER_CONFIG_AGENT}"

    mv "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${DAPP_VPN_CLIENT_CONFIG}" \
       "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${ADAPTER_CONFIG_CLIENT}"
}

copy_artefacts()
{
    if ! [ -f "${ARTEFACTS_LOCATION}" ]; then
        echo Downloading: "${ARTEFACTS_ZIP_URL}"
        curl -o "${ARTEFACTS_LOCATION}" "${ARTEFACTS_ZIP_URL}"
    fi

    unzip "${ARTEFACTS_LOCATION}" \
          -d "${ARTEFACTS_BIN}"

    mv "${ARTEFACTS_BIN}/${OPEN_VPN}" \
       "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${OPEN_VPN}"

    mv "${ARTEFACTS_BIN}/${PGSQL}" \
       "${app_dir}/${PGSQL}"

    mv "${ARTEFACTS_BIN}/${TOR}" \
       "${app_dir}/${TOR}"
}


copy_installer(){
    cp -v "${DAPPINSTALLER_BIN}/${DAPP_INSTALLER}" \
          "${PACKAGE_BIN}/${DAPP_INSTALLER}"

    cp -v "${DAPPINSTALLER_BIN}/${DAPP_INSTALLER_CONFIG}" \
          "${PACKAGE_BIN}/${DAPP_INSTALLER_CONFIG}"
}

build_installer(){
    cp -va "${DAPPINST_DIR}/${INSTALL_BUILDER}/${INSTALL_BUILDER_PROJECT}" \
           "${PACKAGE_INSTALL_BUILDER_BIN}"
    cd "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}"
    "${BITROCK_INSTALLER_BIN}/builder" build "${INSTALL_BUILDER_PROJECT_XML}" osx

    cd "${root_dir}"

    mv -v "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}/out" \
          "${PACKAGE_INSTALL_BUILDER_BIN}"
}

clear

./git/update.sh

./build_installer.sh
./build_ctrl.sh
./build_openvpn.sh
create_gui_package

copy_ctrl
copy_product
copy_artefacts
zip_package
#remove_app
copy_installer
build_installer