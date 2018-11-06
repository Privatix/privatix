#!/usr/bin/env bash

. ${1}

echo copy dappvpn config
cp ./bin/dapp_openvpn/dappvpn.client.config.json \
   ./bin/openvpn_server/config/dappvpn.config.json

echo install openvpn client
cd ./openvpn_server/bin/
sudo openvpn-inst remove
sudo openvpn-inst install -config=../installer.config_client.json

cd ../../
echo prepare dappctrl config
cp "${DAPPCTRL_DIR}"/dappctrl-dev.config.json \
    ./bin/dappctrl.config.json

# change port to `${POSTGRES_PORT}`
sed -i.bu \
    's/"port":  *"[[:digit:]]*"/"port": "'${POSTGRES_PORT}'"/g' \
    ./bin/dappctrl.config.json
# change role to `client`
sed -i.bu \
    's/"Role":  *"agent"/"Role": "client"/g' \
    ./bin/dappctrl.config.json
#change log location to `./bin/log`
sed -i.bu \
    's/\/var\/log/.\/bin\/log/g' \
    ./bin/dappctrl.config.json

echo run dappctrl
dappctrl -config="./bin/dappctrl.config.json" &

echo run dapp-gui
cd ${DAPP_GUI_DIR}
npm start &

sleep 3
jobs -l