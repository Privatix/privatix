#!/usr/bin/env bash

cd `dirname $0`
. ./build.local.config

# run dappctrl
echo run ${DAPPCTRL_BIN}/${DAPPCTRL}
${DAPPCTRL_BIN}/${DAPPCTRL} -config="${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}" &

sleep 3

# run dapp-openvpn
echo run ${OPENVPN_SERVER_BIN}/bin/${DAPP_OPENVPN}
${OPENVPN_SERVER_BIN}/bin/${DAPP_OPENVPN} -config=${OPENVPN_SERVER_BIN}/config/${DAPP_VPN_CONFIG} &

# run gui
echo run ${DAPP_GUI_BIN}
cd ${DAPP_GUI_DIR}
npm start &

# print jobs
sleep 3
jobs -l