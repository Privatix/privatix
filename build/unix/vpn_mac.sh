#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)"
cd "${root_dir}"

. ./build.sealed.config

app_dir="${PACKAGE_BIN_MAC}/${APP}"

clear(){
     rm -rf "${PACKAGE_INSTALL_BUILDER_BIN}"
#    rm -rf "${ARTEFACTS_BIN}"


    mkdir -p "${PACKAGE_BIN_MAC}" || exit 1
    mkdir -p "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}" || exit 1

    mkdir -p "${app_dir}/${DAPPCTRL}" || exit 1
    mkdir -p "${app_dir}/${LOG}" || exit 1
    mkdir -p "${app_dir}/${UTIL}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_DATA}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${LOG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}" || exit 1
    mkdir -p "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}" || exit 1
}

zip_package(){
    cd "${PACKAGE_BIN_MAC}/${APP}"
    zip -r "../${APP_ZIP}" * || exit 1

    cd "${root_dir}"
}

copy_ctrl(){
    cp -v   "${DAPPCTRL_BIN}/${DAPPCTRL}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL}" || exit 1
    cp -v   "${DAPPCTRL_BIN}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" || exit 1
}

copy_product(){
    # binaries
    cp -v "${GOPATH}/bin/${DAPP_OPENVPN}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${DAPP_OPENVPN}" || exit 1

    cp -v "${GOPATH}/bin/${OPENVPN_INST}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${DAPP_INST}" || exit 1

    cp -va "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_SCRIPTS_LOCATION_MAC}/" \
           "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}" || exit 1

    #configs
    for config in ${VPN_CONFIGS_TO_COPY_MAC[@]}
    do
          cp -v "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_INST_PROJECT}/${config}" \
                "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}/${config}" || exit 1
    done

    cp -v "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_PEM_LOCATION}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}" || exit 1

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

    if [[ ! -d "${ARTEFACTS_BIN}" ]]; then
        echo unzip "${ARTEFACTS_LOCATION}"
        unzip "${ARTEFACTS_LOCATION}" \
                -d "${ARTEFACTS_BIN}" || exit 1
    fi

    echo
    echo copy artefacts
    echo

    cp -r "${ARTEFACTS_BIN}/${OPEN_VPN}/." \
       "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${OPEN_VPN}" || exit 1

    cp -r "${ARTEFACTS_BIN}/${PGSQL}/." \
       "${app_dir}/${PGSQL}" || exit 1

    cp -r "${ARTEFACTS_BIN}/${TOR}/." \
       "${app_dir}/${TOR}" || exit 1
}

copy_utils()
{
    echo
    echo copy utils
    echo

    cp -r  "${DUMP_MAC}/." \
       "${app_dir}/${UTIL}/${DUMP}" || exit 1
}

copy_installer(){
    cp -v "${DAPPINSTALLER_BIN}/${DAPP_INSTALLER}" \
          "${PACKAGE_BIN_MAC}/${DAPP_INSTALLER}" || exit 1

    cp -v "${DAPPINSTALLER_BIN}/${DAPP_INSTALLER_CONFIG}" \
          "${PACKAGE_BIN_MAC}/${DAPP_INSTALLER_CONFIG}" || exit 1
}

clear

git/update.sh || exit 1

build/dappctrl.sh || exit 1
build/dapp-installer.sh || exit 1
build/dapp-openvpn.sh || exit 1
build/dapp-gui.sh   "package-mac" \
                    "${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}/." \
                    "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}" \
                    "${DAPP_GUI_SETTINGS_JSON_MAC}" \
                    "${app_dir}" \
                    || exit 1

copy_ctrl
copy_product
copy_artefacts
copy_utils
zip_package
copy_installer

build/bitrock-installer.sh  "${BITROCK_INSTALLER_BIN_MAC}/builder" \
                            "osx" \
                            || exit 1
