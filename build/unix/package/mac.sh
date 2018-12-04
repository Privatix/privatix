#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd "${root_dir}"

. ./build.sealed.config

app_dir="${PACKAGE_BIN}/${APP}"

clear(){
    rm -rf "${PACKAGE_INSTALL_BUILDER_BIN}"
    rm -rf "${ARTEFACTS_BIN}"

    mkdir -p "${PACKAGE_BIN}" || exit 1
    mkdir -p "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}" || exit 1

    mkdir -p "${app_dir}/${DAPPCTRL}" || exit 1
    mkdir -p "${app_dir}/${LOG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_DATA}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${LOG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}" || exit 1
    mkdir -p "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}" || exit 1
}

remove_app(){
    rm -rf "${app_dir}"
}

zip_package(){
    cd "${PACKAGE_BIN}/${APP}"
    zip -r "../${APP_ZIP}" * || exit 1

    cd "${root_dir}"
}

copy_ctrl(){
    cp -v   "${DAPPCTRL_BIN}/${DAPPCTRL}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL}" || exit 1
    cp -v   "${DAPPCTRL_BIN}/${DAPPCTRL_CONFIG}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL_CONFIG}" || exit 1
}

create_gui_package(){
    echo -----------------------------------------------------------------------
    echo create gui package
    echo -----------------------------------------------------------------------

    cd "${DAPP_GUI_DIR}"
    npm i || exit 1
    npm run package-mac || exit 1

    echo
    echo copy ${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}
    echo

    cd ${root_dir}
    rsync -azhP "${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}/." \
                "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}" || exit 1

}

copy_product(){
    # binaries
    cp -v "${GOPATH}/bin/${DAPP_OPENVPN}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${DAPP_OPENVPN}" || exit 1

    cp -v "${GOPATH}/bin/${OPENVPN_INST}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${DAPP_INST}" || exit 1

    #configs
    for config in ${CONFIGS_TO_COPY[@]}
    do
          cp -v "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_INST_PROJECT}/${config}" \
                "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}/${config}" || exit 1
    done

    # templates
    cp -va "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_TEMPLATES_LOCATION}/" \
           "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}" || exit 1

    mv "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${DAPP_VPN_AGENT_CONFIG}" \
       "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${ADAPTER_CONFIG_AGENT}" || exit 1

    mv "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${DAPP_VPN_CLIENT_CONFIG}" \
       "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${ADAPTER_CONFIG_CLIENT}" || exit 1
}

copy_artefacts()
{
    if ! [ -f "${ARTEFACTS_LOCATION}" ]; then
        echo Downloading: "${ARTEFACTS_ZIP_URL}"
        curl -o "${ARTEFACTS_LOCATION}" "${ARTEFACTS_ZIP_URL}" || exit 1
    fi

    unzip "${ARTEFACTS_LOCATION}" \
          -d "${ARTEFACTS_BIN}" || exit 1

    mv "${ARTEFACTS_BIN}/${OPEN_VPN}" \
       "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${OPEN_VPN}" || exit 1

    mv "${ARTEFACTS_BIN}/${PGSQL}" \
       "${app_dir}/${PGSQL}" || exit 1

    mv "${ARTEFACTS_BIN}/${TOR}" \
       "${app_dir}/${TOR}" || exit 1
}


copy_installer(){
    cp -v "${DAPPINSTALLER_BIN}/${DAPP_INSTALLER}" \
          "${PACKAGE_BIN}/${DAPP_INSTALLER}" || exit 1

    cp -v "${DAPPINSTALLER_BIN}/${DAPP_INSTALLER_CONFIG}" \
          "${PACKAGE_BIN}/${DAPP_INSTALLER_CONFIG}" || exit 1
}

build_installer(){
    echo -----------------------------------------------------------------------
    echo build installer gui
    echo -----------------------------------------------------------------------

    cp -va "${DAPPINST_DIR}/${INSTALL_BUILDER}/${INSTALL_BUILDER_PROJECT}" \
           "${PACKAGE_INSTALL_BUILDER_BIN}" || exit 1
    cd "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}" || exit 1
    "${BITROCK_INSTALLER_BIN}/builder" build "${INSTALL_BUILDER_PROJECT_XML}" osx || exit 1

    cd "${root_dir}"

    mv -v "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}/out" \
          "${PACKAGE_INSTALL_BUILDER_BIN}" || exit 1

    echo
    echo done
}

clear

./git/update.sh || exit 1

./build_installer.sh || exit 1
./build_ctrl.sh || exit 1
./build_openvpn.sh || exit 1
create_gui_package

copy_ctrl
copy_product
copy_artefacts
zip_package
#remove_app
copy_installer
build_installer