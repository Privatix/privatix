#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd "${root_dir}"

. ./build.sealed.config

BITROCK_INSTALLER_BIN="/opt/installbuilder-19.2.0/bin"
PACKAGE_BIN=${PACKAGE_INSTALL_BUILDER_BIN}/linux-dapp-installer
DAPP_OPENVPN_SCRIPTS_LOCATION=scripts/linux

DAPP_GUI_PACKAGE_LINUX="release-builds/dapp-gui-linux-x64"
DAPP_GUI_SETTINGS_JSON="resources/app/settings.json"
SCRIPTS_DIR="scripts/linux"
DAPP_INSTALLER_LINUX_CONFIG="dapp-installer.linux.config.json"

CONFIGS_TO_COPY=(
    install.agent.linux.config.json
    install.client.linux.config.json
    installer.agent.config.json
    installer.client.config.json
)

app_dir="${PACKAGE_BIN}/${APP}"

clear(){
    sudo rm -rf "${PACKAGE_INSTALL_BUILDER_BIN}"
    
    mkdir -p "${PACKAGE_BIN}" || exit 1
    mkdir -p "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}" || exit 1

    mkdir -p "${app_dir}/${DAPPCTRL}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_DATA}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${LOG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}" || exit 1
    mkdir -p "${app_dir}/${DAPP_INSTALLER_GUI_DIR}" || exit 1
}

remove_app(){
    rm -rf "${app_dir}"
}

create_container(){
    cd "${PACKAGE_BIN}"
    "./container.sh" || exit 1
    cd "${root_dir}"
}

copy_ctrl(){
    # return log location
    location=${DAPPCTRL_LOG//\//\\/}
    sed -i.b \
        "s/${location}/\/var\/log/g" \
        ${DAPPCTRL_BIN}/${DAPPCTRL_FOR_INSTALLER_CONFIG}

    cp -v   "${DAPPCTRL_BIN}/${DAPPCTRL}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL}" || exit 1
    cp -v   "${DAPPCTRL_BIN}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" || exit 1
    cp -v   "${DAPPINST_DIR}/${SCRIPTS_DIR}/dappctrl.service" \
            "${app_dir}/${DAPPCTRL}/dappctrl.service" || exit 1
    cp -v   "${DAPPINST_DIR}/${SCRIPTS_DIR}/post-stop.sh" \
            "${app_dir}/${DAPPCTRL}/post-stop.sh" || exit 1
    cp -v   "${DAPPINST_DIR}/${SCRIPTS_DIR}/pre-start.sh" \
            "${app_dir}/${DAPPCTRL}/pre-start.sh" || exit 1
    cp -v   "${DAPPINST_DIR}/${SCRIPTS_DIR}/container.sh" \
            "${PACKAGE_BIN}/container.sh" || exit 1
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
    npm run package-linux || exit 1
    echo
    echo copy ${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_LINUX}
    echo

    cd ${root_dir}
    rsync -azhP "${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_LINUX}/." \
                "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/" || exit 1

    # patch settings.json
    python -c 'import json, sys
with open(sys.argv[1], "r") as f:
    obj = json.load(f)
obj["release"]="'${VERSION_TO_SET_IN_BUILDER}'"
obj["target"]="ubuntu"
with open(sys.argv[1], "w") as f:
   json.dump(obj, f)' \
   "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_GUI_SETTINGS_JSON}" || exit 1

}

copy_product(){
    # binaries
    cp -v "${GOPATH}/bin/${DAPP_OPENVPN}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${DAPP_OPENVPN}" || exit 1

    cp -v "${GOPATH}/bin/${OPENVPN_INST}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}/${DAPP_INST}" || exit 1

    cp -va "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_SCRIPTS_LOCATION}/." \
           "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${BIN}" || exit 1

    #configs
    for config in ${CONFIGS_TO_COPY[@]}
    do
        new_name=${config/.linux./.}
        cp -v "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_INST_PROJECT}/${config}" \
            "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}/${new_name}" || exit 1
    done

    cp -v "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_PEM_LOCATION}" \
          "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_CONFIG}" || exit 1

    # templates
    cp -va "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_TEMPLATES_LOCATION}/." \
           "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}" || exit 1

    mv "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${DAPP_VPN_AGENT_CONFIG}" \
       "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${ADAPTER_CONFIG_AGENT}" || exit 1

    mv "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${DAPP_VPN_CLIENT_CONFIG}" \
       "${app_dir}/${PRODUCT}/${PRODUCT_ID}/${PRODUCT_TEMPLATE}/${ADAPTER_CONFIG_CLIENT}" || exit 1
}

copy_installer(){
    cp -v "${DAPPINSTALLER_BIN}/${DAPP_INSTALLER}" \
          "${PACKAGE_BIN}/${DAPP_INSTALLER}" || exit 1

    cp -v "${DAPPINST_DIR}/${DAPP_INSTALLER_LINUX_CONFIG}" \
          "${PACKAGE_BIN}/${DAPP_INSTALLER_CONFIG}" || exit 1
}

build_installer(){
    echo -----------------------------------------------------------------------
    echo build installer gui
    echo -----------------------------------------------------------------------

    cp -va "${DAPPINST_DIR}/${INSTALL_BUILDER}/${INSTALL_BUILDER_PROJECT}" \
           "${PACKAGE_INSTALL_BUILDER_BIN}" || exit 1
    cd "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}" || exit 1
    "${BITROCK_INSTALLER_BIN}/builder" build "${INSTALL_BUILDER_PROJECT_XML}" linux-x64 \
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

./build_installer.sh || exit 1
./build_ctrl.sh || exit 1
./build_openvpn.sh || exit 1

create_gui_package

copy_ctrl
copy_product
create_container
#remove_app
copy_installer
build_installer