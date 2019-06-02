#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)"
cd "${root_dir}"

. ./build.global.config

bin_dir=${BIN}/proxy/mac
installer_bin_dir=${bin_dir}/mac-dapp-installer
app_dir="${installer_bin_dir}/${APP}"

clear(){
    rm -rf "${bin_dir}"
    rm -rf "${PROXY_MAC_OUTPUT_DIR}"


    mkdir -p "${installer_bin_dir}" || exit 1

    mkdir -p "${app_dir}/${DAPPCTRL}" || exit 1
    mkdir -p "${app_dir}/${LOG}" || exit 1
    mkdir -p "${app_dir}/${UTIL}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}/${BIN}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}/${PRODUCT_CONFIG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}/${PRODUCT_DATA}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}/${LOG}" || exit 1
    mkdir -p "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}/${PRODUCT_TEMPLATE}" || exit 1
    mkdir -p "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}" || exit 1

    mkdir -p "${PROXY_MAC_OUTPUT_DIR}" || exit 1
}

zip_package(){
    echo -----------------------------------------------------------------------
    echo zip app
    echo -----------------------------------------------------------------------
    echo Please wait, it takes time...

    echo "${installer_bin_dir}/${APP}"
    cd "${installer_bin_dir}/${APP}"

    zip -qr "../${APP_ZIP}" * || exit 1

    echo && echo done

    cd "${root_dir}"
}

copy_ctrl(){
    echo -----------------------------------------------------------------------
    echo copy dappctrl
    echo -----------------------------------------------------------------------

    cp -v   "${GOPATH}/bin/${DAPPCTRL}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL}" || exit 1
    cp -v   "${DAPPCTRL_DIR}/${DAPPCTRL_CONFIG}" \
            "${app_dir}/${DAPPCTRL}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" || exit 1

   "${PATCH_JSON_SH}" "${app_dir}/${DAPPCTRL}/${DAPPCTRL_FOR_INSTALLER_CONFIG}" \
                                          '["FileLog"]["Level"]="'"${DAPPCTRL_LOG_LEVEL}"'"' \
                                          || exit 1

    echo && echo done
}

copy_product(){
    echo -----------------------------------------------------------------------
    echo copy product binaries
    echo -----------------------------------------------------------------------


    cp -v "${GOPATH}/bin/${DAPP_PROXY}" \
          "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}/${BIN}/${DAPP_PROXY}" || exit 1

    cp -v "${GOPATH}/bin/${DAPP_PROXY_INST}" \
          "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}/${BIN}/${DAPP_INST}" || exit 1

    echo && echo done

    echo -----------------------------------------------------------------------
    echo copy product templates
    echo -----------------------------------------------------------------------


    # templates
    cp -va "${DAPP_PROXY_DIR}/${DAPP_PROXY_PRODUCT}/" \
           "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}" || exit 1

    echo && echo done
}

copy_artefacts()
{
    echo -----------------------------------------------------------------------
    echo copy artefacts
    echo -----------------------------------------------------------------------


    if ! [ -f "${ARTEFACTS_LOCATION}" ]; then
        echo Downloading: "${ARTEFACTS_MAC_ZIP_URL}"
        curl -o "${ARTEFACTS_LOCATION}" "${ARTEFACTS_MAC_ZIP_URL}" || exit 1
    fi

    if [[ ! -d "${ARTEFACTS_BIN}" ]]; then
        echo unzip "${ARTEFACTS_LOCATION}"
        unzip "${ARTEFACTS_LOCATION}" \
                -d "${ARTEFACTS_BIN}" || exit 1
    fi

    echo "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}/${BIN}/${V2RAY}"
    cp -r "${ARTEFACTS_BIN}/${V2RAY}/." \
       "${app_dir}/${PRODUCT}/${PROXY_PRODUCT_ID}/${BIN}/${V2RAY}" || exit 1

    echo "${app_dir}/${PGSQL}"
    cp -r "${ARTEFACTS_BIN}/${PGSQL}/." \
       "${app_dir}/${PGSQL}" || exit 1

    echo "${app_dir}/${TOR}"
    cp -r "${ARTEFACTS_BIN}/${TOR}/." \
       "${app_dir}/${TOR}" || exit 1

    echo && echo done
}

copy_utils()
{
    echo -----------------------------------------------------------------------
    echo copy utils
    echo -----------------------------------------------------------------------

    echo "${app_dir}/${UTIL}/${DUMP}"
    cp -r  "${DUMP_MAC}/." \
       "${app_dir}/${UTIL}/${DUMP}" || exit 1

    echo && echo done
}

copy_installer(){
    echo -----------------------------------------------------------------------
    echo copy dapp-installer
    echo -----------------------------------------------------------------------


    cp -v "${GOPATH}/bin/${DAPP_INSTALLER}" \
          "${installer_bin_dir}/${DAPP_INSTALLER}" || exit 1

    cp -v "${DAPP_INSTALLER_DIR}/${DAPP_INSTALLER_CONFIG}" \
          "${installer_bin_dir}/${DAPP_INSTALLER_CONFIG}" || exit 1

    echo && echo done
}

clear

git/update.sh || exit 1

if [[ -z "$1" ]] || [[ "$1" != "--keep_common_binaries" ]]; then
    build/dappctrl.sh || exit 1
    build/dapp-installer.sh || exit 1
    build/dapp-gui.sh   "package-mac" \
                        "${DAPP_GUI_DIR}/${DAPP_GUI_PACKAGE_MAC}/${DAPP_GUI_PACKAGE_MAC_BINARY_NAME}/." \
                        "${app_dir}/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}" \
                        "${DAPP_GUI_SETTINGS_JSON_MAC}" \
                        "proxy_osx" \
                        || exit 1
fi

build/dapp-proxy.sh || exit 1

copy_ctrl
copy_product
copy_artefacts
copy_utils
zip_package
copy_installer

build/bitrock-installer.sh  "${BITROCK_INSTALLER_BIN_MAC}/builder" \
                            "osx" \
                            "${PROXY_PRODUCT_ID}" \
                            "${PROXY_PRODUCT_NAME}" \
                            "" \
                            "${bin_dir}" \
                            "${PROXY_MAC_OUTPUT_DIR}" \
                            "privatix_proxy_osx_x64_${VERSION_TO_SET_IN_BUILDER}_installer" \
                            || exit 1
