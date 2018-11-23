#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

# install
echo
echo install products
echo

openvpn=${OPENVPN_SERVER_BIN}/bin/openvpn

clean(){
    rm -rf ${OPENVPN_SERVER_BIN}
    rm -rf ${OPENVPN_CLIENT_BIN}

    mkdir -p ${OPENVPN_SERVER_BIN}/bin
    mkdir -p ${OPENVPN_SERVER_BIN}/config
    mkdir -p ${OPENVPN_SERVER_BIN}/log
    mkdir -p ${openvpn}

    mkdir -p ${OPENVPN_CLIENT_BIN}/config
    mkdir -p ${OPENVPN_CLIENT_BIN}/log
}

install(){
    connection_string="dbname=dappctrl host=localhost sslmode=disable \
user=${POSTGRES_USER} \
port=${POSTGRES_PORT} \
${POSTGRES_PASSWORD:+ password=${POSTGRES_PASSWORD}}"

    echo Connection string: ${connection_string}

    ${DAPP_OPENVPN_BIN}/${DAPP_OPENVPN_INST} \
     -rootdir=${DAPP_OPENVPN_BIN}/ \
     -connstr="$connection_string" -setauth
}

copy_binaries(){
    # openvpn_server
    cp -v ${OPENVPN_INST_DIR}/openvpn-down-root.so \
          ${openvpn}/openvpn-down-root.so

    # openvpn & openssl
    cp -v $(which openssl) \
          ${openvpn}/openssl

    cp -v $(which openvpn) \
          ${openvpn}/openvpn

          # openvpn-inst & dappvpn
    cp -v ${DAPP_OPENVPN_BIN}/${OPENVPN_INST} \
          ${OPENVPN_SERVER_BIN}/bin/${OPENVPN_INST}

    cp -v ${DAPP_OPENVPN_BIN}/${DAPP_OPENVPN} \
          ${OPENVPN_SERVER_BIN}/bin/${DAPP_OPENVPN}
}

copy_configs(){
    # configs
    echo
    echo copy configs
    cp -v ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG} \
          ${OPENVPN_SERVER_BIN}/config/${DAPP_VPN_CONFIG}

    cp -v ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG} \
          ${OPENVPN_CLIENT_BIN}/config/${DAPP_VPN_CONFIG}

    cp -v ${OPENVPN_INST_DIR}/${INSTALLER_AGENT_CONFIG} \
          ${OPENVPN_SERVER_BIN}/${INSTALLER_CONFIG}

    cp -v ${OPENVPN_INST_DIR}/${INSTALLER_CLIENT_CONFIG} \
          ${OPENVPN_CLIENT_BIN}/${INSTALLER_CONFIG}
}

clean
install
copy_binaries
copy_configs