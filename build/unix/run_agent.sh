#!/usr/bin/env bash

cd `dirname $0`
. ./build.sealed.config

# run dappctrl
echo run ${DAPPCTRL_BIN}/${DAPPCTRL}
${DAPPCTRL_BIN}/${DAPPCTRL} -config="${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}" &

sleep 3

# run dapp-openvpn
echo run ${OPENVPN_AGENT_BIN}/bin/${DAPP_OPENVPN}
sudo ${OPENVPN_AGENT_BIN}/bin/${DAPP_OPENVPN} -config=${OPENVPN_AGENT_BIN}/config/${DAPP_VPN_CONFIG} &

sleep 5

# run gui
echo run ${DAPP_GUI_BIN}
cd ${DAPP_GUI_DIR}
npm start &