#!/usr/bin/env bash

. ${1}

echo run dappctrl
./bin/dappctrl -config="./bin/dappctrl.agent.config.json" &

echo run dapp-openvpn
./bin/openvpn_server/bin/dappvpn -config=./bin/openvpn_server/config/dappvpn.config.json &

echo run dapp-gui
cd ${DAPP_GUI_DIR}
npm start &

sleep 3
jobs -l