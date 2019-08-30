#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)"
cd "${root_dir}"

. ./build.global.config


bin_dir=${BIN}/vpn/ubuntu
installer_bin_dir=${bin_dir}/linux-dapp-installer
app_dir="${installer_bin_dir}/${APP}"

clear(){
    sudo rm -rf "${bin_dir}"
    rm -rf "${VPN_UBUNTU_OUTPUT_DIR}"
    
    mkdir -p "${installer_bin_dir}" || exit 1

    mkdir -p "${app_dir}/${DAPPCTRL}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${BIN}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_CONFIG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_DATA}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${LOG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${VPN_PRODUCT_ID}/${PRODUCT_TEMPLATE}" || exit 1
    mkdir -p "${app_dir}/${DAPP_INSTALLER_GUI_DIR}" || exit 1
    mkdir -p "${app_dir}/${UTIL}" || exit 1

    mkdir -p "${VPN_UBUNTU_OUTPUT_DIR}"
}

copy_ctrl(){
    echo -----------------------------------------------------------------------
    echo copy dappctrl
    echo -----------------------------------------------------------------------


    # return log location
    location=${DAPPCTRL_LOG//\//\\/}
    sed -i.b \
        "s/${location}/\/var\/log/g" \
        ${DAPPCTRL_DIR}/${DAPPCTRL_FOR_INSTALLER_CONFIG}

    cp -v   "${GOPATH}/bin/${DAPPCTRL}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL}" || exit 1
    cp -v   "${DAPPCTRL_DIR}/${DAPPCTRL_CONFIG}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" || exit 1

    # scripts
    cp -va  "${DAPP_INSTALLER_DIR}/scripts/linux/." \
            "${app_dir}/${DAPPCTRL}"

   "${PATCH_JSON_SH}" "${app_dir}/${DAPPCTRL}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" \
                                          '["FileLog"]["Level"]="'"${DAPPCTRL_LOG_LEVEL}"'"' \
                                          || exit 1

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
          "${installer_bin_dir}/${DAPP_INSTALLER}" || exit 1
    cp -v "${GOPATH}/bin/${DAPP_SUPERVISOR}" \
          "${installer_bin_dir}/${DAPP_SUPERVISOR}" || exit 1

    cp -v "${DAPP_INSTALLER_DIR}/${DAPP_INSTALLER_LINUX_CONFIG}" \
          "${installer_bin_dir}/${DAPP_INSTALLER_CONFIG}" || exit 1

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

if [[ -z "$1" ]] || [[ "$1" != "--keep_common_binaries" ]]; then
    build/dappctrl.sh || exit 1
    build/dapp-installer.sh || exit 1
    build/dapp-gui.sh   "package-linux" \
                        "${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_LINUX}/." \
                        "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/" \
                        "${DAPP_GUI_SETTINGS_JSON_LINUX}" \
                        "ubuntu" \
                        "\$HOME/.config/privatix" \
                        || exit 1
fi

build/dapp-openvpn.sh || exit 1

copy_ctrl
copy_product
copy_utils

build/container_ubuntu.sh "${installer_bin_dir}" || exit 1

copy_installer
#deb_package_dir="privatix_ubuntu_x64_${VERSION_TO_SET_IN_BUILDER}_cli"

build/bitrock-installer.sh  "${BITROCK_INSTALLER_BIN_LINUX}/builder" \
                            "linux-x64" \
                            "${VPN_PRODUCT_ID}" \
                            "${VPN_PRODUCT_NAME}" \
                            "1" \
                            "${bin_dir}" \
                            "${VPN_UBUNTU_OUTPUT_DIR}" \
                            || exit 1

build/deb.sh "${installer_bin_dir}" \
             "${VPN_UBUNTU_OUTPUT_DIR}" \
             || exit 1