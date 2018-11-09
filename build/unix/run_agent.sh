#!/usr/bin/env bash

cd `dirname $0`
. ./build.local.config

# run dappctrl
echo run dappctrl
./bin/dappctrl -config="./bin/dappctrl.agent.config.json" &

sleep 3

# run dapp-openvpn
echo run dapp-openvpn
./bin/openvpn_server/bin/dappvpn -config=./bin/openvpn_server/config/dappvpn.config.json &

# run gui
echo run dapp-gui
cd ./bin/dapp_gui
npm start &

# print jobs
sleep 3
jobs -l