#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

# install
echo
echo install products
echo

openvpn=${OPENVPN_AGENT_BIN}/bin/openvpn

clean(){
    rm -rf ${OPENVPN_AGENT_BIN}
    rm -rf ${OPENVPN_CLIENT_BIN}

    mkdir -p ${OPENVPN_AGENT_BIN}/bin
    mkdir -p ${OPENVPN_AGENT_BIN}/config
    mkdir -p ${OPENVPN_AGENT_BIN}/log
    mkdir -p ${OPENVPN_AGENT_BIN}/data
    mkdir -p ${OPENVPN_AGENT_BIN}/${PRODUCT_TEMPLATE}/${DAPP_OPENVPN_TEMPLATES}
    mkdir -p ${OPENVPN_AGENT_BIN}/${PRODUCT_TEMPLATE}/${DAPP_OPENVPN_PRODUCTS}
    mkdir -p ${openvpn}
}


prepare_install(){
    cp -v "${GOPATH}"/bin/${DAPP_OPENVPN_INST} \
          ${OPENVPN_AGENT_BIN}/bin/${DAPP_OPENVPN_INST}

    cp -v "${GOPATH}"/bin/${DAPP_OPENVPN} \
          ${OPENVPN_AGENT_BIN}/bin/${DAPP_OPENVPN}

    cp -v "${GOPATH}"/bin/${OPENVPN_INST} \
          ${OPENVPN_AGENT_BIN}/bin/${OPENVPN_INST}

    cp -av "${DAPP_OPENVPN_DIR}"/${DAPP_OPENVPN_TEMPLATES_LOCATION}/ \
           ${OPENVPN_AGENT_BIN}/${PRODUCT_TEMPLATE}

    cp -v ${OPENVPN_INST_DIR}/openvpn-down-root.so \
          ${openvpn}/openvpn-down-root.so

    # openvpn & openssl
    cp -v $(which openssl) \
          ${openvpn}/openssl

    cp -v $(which openvpn) \
          ${openvpn}/openvpn
}

install(){
    echo
    echo install
    echo

    connection_string="dbname=dappctrl host=localhost sslmode=disable \
user=${POSTGRES_USER} \
port=${POSTGRES_PORT} \
${POSTGRES_PASSWORD:+ password=${POSTGRES_PASSWORD}}"

    echo Connection string: ${connection_string}

    ${OPENVPN_AGENT_BIN}/bin/${DAPP_OPENVPN_INST} \
     -rootdir="${OPENVPN_AGENT_BIN}/${PRODUCT_TEMPLATE}" \
     -connstr="$connection_string" -setauth

    echo
}

copy_client(){
    cp -va ${OPENVPN_AGENT_BIN}/ \
           ${OPENVPN_CLIENT_BIN}
}

copy_configs(){
    # dapp-openvpn configs


    # installer configs
    cp -v ${OPENVPN_INST_DIR}/${INSTALLER_AGENT_CONFIG} \
          ${OPENVPN_AGENT_BIN}/config/${INSTALLER_CONFIG}

    cp -v ${OPENVPN_INST_DIR}/${INSTALLER_CLIENT_CONFIG} \
          ${OPENVPN_CLIENT_BIN}/config/${INSTALLER_CONFIG}
}

prepare_configs(){
    cp -v ${OPENVPN_AGENT_BIN}/${PRODUCT_TEMPLATE}/${DAPP_VPN_AGENT_CONFIG} \
          ${OPENVPN_AGENT_BIN}/config/${DAPP_VPN_CONFIG}

    cp -v ${OPENVPN_CLIENT_BIN}/${PRODUCT_TEMPLATE}/${DAPP_VPN_CLIENT_CONFIG} \
          ${OPENVPN_CLIENT_BIN}/config/${DAPP_VPN_CONFIG}

    # change log location
    # agent
    location=${OPENVPN_AGENT_BIN}/log
    location=${location//\//\\/}
    sed_string="s/\/var\/log/${location}/g"
    sed -i.b \
        ${sed_string} \
        ${OPENVPN_AGENT_BIN}/config/${DAPP_VPN_CONFIG}

    # client
    location=${OPENVPN_CLIENT_BIN}/log
    location=${location//\//\\/}
    sed_string="s/\/var\/log/${location}/g"
    sed -i.b \
        ${sed_string} \
        ${OPENVPN_CLIENT_BIN}/config/${DAPP_VPN_CONFIG}

    # change open_vpn location
    # agent
    location=${OPENVPN_AGENT_BIN//\//\\/}
    sed -i.b \
        "s/\/etc\/openvpn/${location}/g" \
        ${OPENVPN_AGENT_BIN}/config/${DAPP_VPN_CONFIG}

    # client
    location=${OPENVPN_CLIENT_BIN//\//\\/}
    sed -i.b \
        "s/\/etc\/openvpn/${location}/g" \
        ${OPENVPN_CLIENT_BIN}/config/${DAPP_VPN_CONFIG}
}

print_diff(){
    echo
    echo ${DAPP_VPN_CLIENT_CONFIG}
    diff ${OPENVPN_CLIENT_BIN}/${PRODUCT_TEMPLATE}/${DAPP_VPN_CLIENT_CONFIG} \
         ${OPENVPN_CLIENT_BIN}/config/${DAPP_VPN_CONFIG}

    echo
    echo ${DAPP_VPN_AGENT_CONFIG}
    diff ${OPENVPN_AGENT_BIN}/${PRODUCT_TEMPLATE}/${DAPP_VPN_AGENT_CONFIG} \
         ${OPENVPN_AGENT_BIN}/config/${DAPP_VPN_CONFIG}
}

clean
prepare_install
install
copy_client
copy_configs
prepare_configs
print_diff