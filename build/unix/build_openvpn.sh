#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

echo
echo dapp-openvpn
echo

clean(){
    rm "${GOPATH}"/bin/${DAPP_OPENVPN_INST}
    rm "${GOPATH}"/bin/${DAPP_OPENVPN}
    rm "${GOPATH}"/bin/${OPENVPN_INST}

    rm -rf ${DAPP_OPENVPN_BIN}
    mkdir -p ${DAPP_OPENVPN_BIN}
    mkdir -p ${DAPP_OPENVPN_LOG}
}

build(){
    export DAPP_OPENVPN_DIR

    "${DAPP_OPENVPN_DIR}"/scripts/build.sh

    cp -v "${GOPATH}"/bin/${DAPP_OPENVPN_INST} \
          ${DAPP_OPENVPN_BIN}/${DAPP_OPENVPN_INST}

    cp -v "${GOPATH}"/bin/${DAPP_OPENVPN} \
          ${DAPP_OPENVPN_BIN}/${DAPP_OPENVPN}

    cp -v "${GOPATH}"/bin/${OPENVPN_INST} \
          ${DAPP_OPENVPN_BIN}/${OPENVPN_INST}
}

copy_templates(){
    cp -av "${DAPP_OPENVPN_DIR}"/${DAPP_OPENVPN_TEMPLATES_LOCATION}/products \
           ${DAPP_OPENVPN_BIN}/products

    cp -av "${DAPP_OPENVPN_DIR}"/${DAPP_OPENVPN_TEMPLATES_LOCATION}/templates \
           ${DAPP_OPENVPN_BIN}/templates

    cp -v "${DAPP_OPENVPN_DIR}"/${DAPP_OPENVPN_TEMPLATES_LOCATION}/${DAPP_VPN_AGENT_CONFIG} \
          ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}

    cp -v "${DAPP_OPENVPN_DIR}"/${DAPP_OPENVPN_TEMPLATES_LOCATION}/${DAPP_VPN_CLIENT_CONFIG} \
          ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}
}

prepare_configs(){
    cp -v ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG} \
          ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}_source
    cp -v ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG} \
          ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}_source

    # change log location to ${DAPP_OPENVPN_LOG}
    location=${DAPP_OPENVPN_LOG//\//\\/}
    sed_string="s/\/var\/log/${location}/g"
    sed -i.b \
        ${sed_string} \
        ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}

    # change log location to ${DAPP_OPENVPN_LOG}
    sed -i.b \
        ${sed_string} \
        ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}

    # change open_vpn location to ${OPENVPN_SERVER_BIN}
    location=${OPENVPN_SERVER_BIN//\//\\/}
    sed -i.b \
        "s/\/etc\/openvpn/${location}/g" \
        ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}
}

print_diff(){
    echo
    echo ${DAPP_VPN_CLIENT_CONFIG}
    diff ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}_source \
         ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}

    echo
    echo ${DAPP_VPN_AGENT_CONFIG}
    diff ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}_source \
         ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}

}

clean
build
copy_templates
prepare_configs
print_diff