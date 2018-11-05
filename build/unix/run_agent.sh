#!/usr/bin/env bash

. ${1}

echo copy dappvpn config
cp ./openvpn_server/dappvpn.agent.config.json \
   ./openvpn_server/config/dappvpn.config.json

echo install openvpn server
cd ./openvpn_server/bin/
sudo openvpn-inst remove
sudo openvpn-inst install -config=../installer.config_agent.json

echo run openvpn server
sudo openvpn-inst run &

#sleep 10
cd ../../
echo prepare dappctrl config
cp "${DAPPCTRL_DIR}"/dappctrl-dev.config.json \
    ./bin/dappctrl.config.json

sed -i.bu \
    's/"port":  *"[[:digit:]]*"/"port": "'${POSTGRES_PORT}'"/g' \
    ./bin/dappctrl.config.json

echo run dappctrl
dappctrl -config="./bin/dappctrl.config.json" &

echo run dapp-openvpn
./openvpn_server/bin/dappvpn -config=./openvpn_server/config/dappvpn.config.json &

echo run dapp-gui
cd ${DAPP_GUI_DIR}
npm start &

sleep 3
jobs -l