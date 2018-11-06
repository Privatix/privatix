#!/usr/bin/env bash

. ${1}

echo run dappctrl
dappctrl -config="./bin/dappctrl.config.json" &

echo run dapp-openvpn
./openvpn_server/bin/dappvpn -config=./openvpn_server/config/dappvpn.config.json &

echo run dapp-gui
cd ${DAPP_GUI_DIR}
npm start &

sleep 3
jobs -l