#!/usr/bin/env bash

. ${1}

echo Run openvpn server

echo Copy dappvpn.agent.config.json
cp "${DAPP_OPENVPN_DIR}"/bin/example/dappvpn.agent.config.json ./openvpn_server/config/dappvpn.config.json

cd ./openvpn_server/bin
sudo openvpn-inst remove
sudo openvpn-inst install -config=../installer.config_agent.json

sudo openvpn-inst run &

jobs -l

#"${DAPP_OPENVPN_DIR}"/scripts/run_adapter_agent.sh