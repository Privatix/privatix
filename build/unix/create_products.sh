#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

# install
echo
echo install products

${DAPP_OPENVPN_BIN}/${DAPP_OPENVPN_INST} \
 -rootdir=${DAPP_OPENVPN_BIN}/ \
 -connstr="dbname=dappctrl host=localhost user=postgres \
  sslmode=disable port=${POSTGRES_PORT}" -setauth

# binaries
echo
echo copy binaries

#clear
openvpn=${OPENVPN_SERVER_BIN}/bin/openvpn

rm -rf ${OPENVPN_SERVER_BIN}

mkdir -p ${OPENVPN_SERVER_BIN}/bin
mkdir -p ${OPENVPN_SERVER_BIN}/config
mkdir -p ${OPENVPN_SERVER_BIN}/log
mkdir -p ${openvpn}

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

# configs
echo
echo copy configs
cp -v ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG} \
      ${OPENVPN_SERVER_BIN}/config/${DAPP_VPN_CONFIG}

cp -v ${OPENVPN_INST_DIR}/${INSTALLER_AGENT_CONFIG} \
      ${OPENVPN_SERVER_BIN}/${INSTALLER_CONFIG}