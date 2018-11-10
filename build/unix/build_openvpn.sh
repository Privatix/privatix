#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

export DAPP_OPENVPN_DIR

echo
echo dapp-openvpn
cd "${DAPP_OPENVPN_DIR}"

# build
echo
echo build start
rm "${GOPATH}"/bin/${DAPP_OPENVPN_INST}
rm "${GOPATH}"/bin/${DAPP_OPENVPN}
rm "${GOPATH}"/bin/${OPENVPN_INST}

"${DAPP_OPENVPN_DIR}"/scripts/build.sh

# binaries
cd ${root_dir}

# clear
rm -rf ${DAPP_OPENVPN_BIN}
mkdir -p ${DAPP_OPENVPN_BIN}
mkdir -p ${DAPP_OPENVPN_LOG}

echo
echo copy binaries

cp -v "${GOPATH}"/bin/${DAPP_OPENVPN_INST} \
      ${DAPP_OPENVPN_BIN}/${DAPP_OPENVPN_INST}

cp -v "${GOPATH}"/bin/${DAPP_OPENVPN} \
      ${DAPP_OPENVPN_BIN}/${DAPP_OPENVPN}

cp -v "${GOPATH}"/bin/${OPENVPN_INST} \
      ${DAPP_OPENVPN_BIN}/${OPENVPN_INST}

# configs
echo
echo copy configs

cp -av "${DAPP_OPENVPN_DIR}"/${DAPP_OPENVPN_TEMPLATES_LOCATION}/products \
       ${DAPP_OPENVPN_BIN}/products

cp -av "${DAPP_OPENVPN_DIR}"/${DAPP_OPENVPN_TEMPLATES_LOCATION}/templates \
       ${DAPP_OPENVPN_BIN}/templates

cp -v "${DAPP_OPENVPN_DIR}"/${DAPP_OPENVPN_TEMPLATES_LOCATION}/${DAPP_VPN_AGENT_CONFIG} \
      ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}

cp -v "${DAPP_OPENVPN_DIR}"/${DAPP_OPENVPN_TEMPLATES_LOCATION}/${DAPP_VPN_CLIENT_CONFIG} \
      ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}


# patch
echo
echo patch configs
# change log location to ${DAPP_OPENVPN_LOG}
location=${DAPP_OPENVPN_LOG//\//\\/}
sed_string="s/\/var\/log/${location}/g"
sed -i.bu \
    ${sed_string} \
    ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}

# change log location to ${DAPP_OPENVPN_LOG}
sed -i.bu \
    ${sed_string} \
    ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}


# change open_vpn location to ${OPENVPN_SERVER_BIN}
location=${OPENVPN_SERVER_BIN//\//\\/}
sed -i.bu \
    "s/\/etc\/openvpn/${location}/g" \
    ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}

# change open_vpn location to ${OPENVPN_CLIENT_BIN}
location=${OPENVPN_CLIENT_BIN//\//\\/}
sed -i.bu \
    "s/\/etc\/openvpn/${location}/g" \
    ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}

echo
echo ${DAPP_VPN_CLIENT_CONFIG}
diff ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}.bu \
     ${DAPP_OPENVPN_BIN}/${DAPP_VPN_CLIENT_CONFIG}

echo
echo ${DAPP_VPN_AGENT_CONFIG}
diff ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}.bu \
     ${DAPP_OPENVPN_BIN}/${DAPP_VPN_AGENT_CONFIG}