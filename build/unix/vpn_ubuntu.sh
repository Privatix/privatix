#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)"
cd "${root_dir}"

. ./build.global.config


app_dir="${PACKAGE_BIN_LINUX}/${APP}"

clear(){
    sudo rm -rf "${PACKAGE_INSTALL_BUILDER_BIN}"
    
    mkdir -p "${PACKAGE_BIN_LINUX}" || exit 1
    mkdir -p "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}" || exit 1

    mkdir -p "${app_dir}/${DAPPCTRL}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${BIN}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_CONFIG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_DATA}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${LOG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_TEMPLATE}" || exit 1
    mkdir -p "${app_dir}/${DAPP_INSTALLER_GUI_DIR}" || exit 1
    mkdir -p "${app_dir}/${UTIL}" || exit 1
}

copy_ctrl(){
    echo -----------------------------------------------------------------------
    echo copy dappctrl
    echo -----------------------------------------------------------------------


    # return log location
    location=${DAPPCTRL_LOG//\//\\/}
    sed -i.b \
        "s/${location}/\/var\/log/g" \
        ${DAPPCTRL_BIN}/${DAPPCTRL_FOR_INSTALLER_CONFIG}

    cp -v   "${GOPATH}/bin/${DAPPCTRL}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL}" || exit 1
    cp -v   "${DAPPCTRL_DIR}/${DAPPCTRL_CONFIG}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" || exit 1
    cp -v   "${DAPP_INSTALLER_DIR}/${DAPP_INSTALLER_SCRIPTS_DIR_LINUX}/dappctrl.service" \
            "${app_dir}/${DAPPCTRL}/dappctrl.service" || exit 1
    cp -v   "${DAPP_INSTALLER_DIR}/${DAPP_INSTALLER_SCRIPTS_DIR_LINUX}/post-stop.sh" \
            "${app_dir}/${DAPPCTRL}/post-stop.sh" || exit 1
    cp -v   "${DAPP_INSTALLER_DIR}/${DAPP_INSTALLER_SCRIPTS_DIR_LINUX}/pre-start.sh" \
            "${app_dir}/${DAPPCTRL}/pre-start.sh" || exit 1

    # patch ${DAPPCTRL_CONFIG}
    python -c 'import json, sys
with open(sys.argv[1], "r") as f:
    obj = json.load(f)
obj["ReportLog"]["Level"]="'${DAPPCTRL_LOG_LEVEL}'"
with open(sys.argv[1], "w") as f:
   json.dump(obj, f)' \
   "${app_dir}/${DAPPCTRL}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" || exit 1

    echo && echo done
}

copy_product(){
    echo -----------------------------------------------------------------------
    echo copy product binaries
    echo -----------------------------------------------------------------------


    # binaries
    cp -v "${GOPATH}/bin/${DAPP_OPENVPN}" \
          "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${BIN}/${DAPP_OPENVPN}" || exit 1

    cp -v "${GOPATH}/bin/${OPENVPN_INST}" \
          "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${BIN}/${DAPP_INST}" || exit 1

    cp -va "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_SCRIPTS_LOCATION_LINUX}/." \
           "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${BIN}" || exit 1

    echo && echo done
    echo -----------------------------------------------------------------------
    echo copy product configs
    echo -----------------------------------------------------------------------


    #configs
    for config in ${VPN_CONFIGS_TO_COPY_UBUNTU[@]}
    do
        new_name=${config/.linux./.}
        cp -v "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_INST_PROJECT}/${config}" \
            "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_CONFIG}/${new_name}" || exit 1
    done

    cp -v "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_PEM_LOCATION}" \
          "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_CONFIG}" || exit 1

    echo && echo done
    echo -----------------------------------------------------------------------
    echo copy product templates
    echo -----------------------------------------------------------------------


    # templates
    cp -va "${DAPP_OPENVPN_DIR}/${DAPP_OPENVPN_TEMPLATES_LOCATION}/." \
           "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_TEMPLATE}" || exit 1

    mv "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_TEMPLATE}/${DAPP_VPN_AGENT_CONFIG}" \
       "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_TEMPLATE}/${ADAPTER_CONFIG_AGENT}" || exit 1

    mv "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_TEMPLATE}/${DAPP_VPN_CLIENT_CONFIG}" \
       "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_TEMPLATE}/${ADAPTER_CONFIG_CLIENT}" || exit 1

    echo && echo done
}

copy_installer(){
    echo -----------------------------------------------------------------------
    echo copy dapp-installer
    echo -----------------------------------------------------------------------

    cp -v "${GOPATH}/bin/${DAPP_INSTALLER}" \
          "${PACKAGE_BIN_LINUX}/${DAPP_INSTALLER}" || exit 1

    cp -v "${DAPP_INSTALLER_DIR}/${DAPP_INSTALLER_LINUX_CONFIG}" \
          "${PACKAGE_BIN_LINUX}/${DAPP_INSTALLER_CONFIG}" || exit 1

    echo && echo done
}

copy_utils()
{
    echo -----------------------------------------------------------------------
    echo copy utils
    echo -----------------------------------------------------------------------

    echo "${app_dir}/${UTIL}/${DUMP}"
    cp -r  "${DUMP_LINUX}/." \
       "${app_dir}/${UTIL}/${DUMP}" || exit 1


    echo && echo done
}


clear

git/update.sh || exit 1

build/dappctrl.sh || exit 1
build/dapp-installer.sh || exit 1
build/dapp-openvpn.sh || exit 1
build/dapp-gui.sh   "package-linux" \
                    "${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_LINUX}/." \
                    "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/" \
                    "${DAPP_GUI_SETTINGS_JSON_LINUX}" \
                    "ubuntu" \
                    || exit 1

copy_ctrl
copy_product
copy_utils

build/container_ubuntu.sh || exit 1

copy_installer

build/bitrock-installer.sh  "${BITROCK_INSTALLER_BIN_LINUX}/builder" \
                            "linux-x64" \
                            "${VPN_PRODUCT_ID}" \
                            "${VPN_PRODUCT_NAME}" \
                             "s/<requireInstallationByRootUser>0/<requireInstallationByRootUser>1/g" \
                            || exit 1