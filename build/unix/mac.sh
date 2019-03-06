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

remove_app(){
    rm -rf "${app_dir}"
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

create_gui_package(){
    echo -----------------------------------------------------------------------
    echo create gui package
    echo -----------------------------------------------------------------------

    cd "${DAPP_GUI_DIR}"
    rm -rf ./build/
    rm -rf ./release-builds/

    npm i || exit 1
    npm run build || exit 1
    npm run package-mac || exit 1
    echo
    echo copy ${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}
    echo

    cd ${root_dir}
    rsync -azhP "${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}/." \
                "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}" || exit 1

    # patch settings.json
    python -c 'import json, sys
with open(sys.argv[1], "r") as f:
    obj = json.load(f)
obj["release"]="'${VERSION_TO_SET_IN_BUILDER}'"
obj["target"]="osx"
with open(sys.argv[1], "w") as f:
   json.dump(obj, f)' \
   "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}/${DAPP_GUI_SETTINGS_JSON_MAC}" || exit 1

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
    for config in ${CONFIGS_TO_COPY[@]}
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

build_installer(){
    echo -----------------------------------------------------------------------
    echo build installer gui
    echo -----------------------------------------------------------------------

    cp -va "${DAPPINST_DIR}/${INSTALL_BUILDER}/${INSTALL_BUILDER_PROJECT}" \
           "${PACKAGE_INSTALL_BUILDER_BIN}" || exit 1
    cd "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}" || exit 1
    "${BITROCK_INSTALLER_BIN_MAC}/builder" build "${INSTALL_BUILDER_PROJECT_XML}" osx \
                            --setvars project.version=${VERSION_TO_SET_IN_BUILDER} \
                            || exit 1

    cd "${root_dir}"

    mv -v "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}/out" \
          "${PACKAGE_INSTALL_BUILDER_BIN}" || exit 1

    echo
    echo done
}

clear

./git/update.sh || exit 1

./build/build_installer.sh || exit 1
./build/build_ctrl.sh || exit 1
./build/build_openvpn.sh || exit 1
create_gui_package

copy_ctrl
copy_product
copy_artefacts
copy_utils
zip_package
#remove_app
copy_installer
build_installer