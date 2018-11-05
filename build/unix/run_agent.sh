#!/usr/bin/env bash

. ${1}

echo Run openvpn server

# CONFIG
echo Copy dappvpn.agent.config.json
cp "${DAPP_OPENVPN_DIR}"/bin/example/dappvpn.agent.config.json ./openvpn_server/config/dappvpn.config.json

# INSTALL
cd ./openvpn_server/bin
sudo openvpn-inst remove
sudo openvpn-inst install -config=../installer.config_agent.json

# RUN
sudo openvpn-inst run &

sleep 10
"${DAPP_OPENVPN_DIR}"/scripts/run_adapter_agent.sh &

cp "${DAPPCTRL_DIR}"/dappctrl-dev.config.json "${DAPPCTRL_DIR}"/dappctrl.config.local.json
sed -i.bu 's/"port":  *"[[:digit:]]*"/"port": "'${POSTGRES_PORT}'"/g' "${DAPPCTRL_DIR}"/dappctrl.config.local.json

"${DAPPCTRL_DIR}"/scripts/run.sh &

jobs -l