#!/usr/bin/env bash

. ${1}

echo copy configs

# DAPPVPN
cp -a "${DAPP_OPENVPN_DIR}"/files/example/products \
      ./bin/dapp_openvpn/products

cp -a "${DAPP_OPENVPN_DIR}"/files/example/templates \
      ./bin/dapp_openvpn/templates

cp "${DAPP_OPENVPN_DIR}"/files/example/dappvpn.agent.config.json \
   ./bin/dapp_openvpn/dappvpn.agent.config.json

cp "${DAPP_OPENVPN_DIR}"/files/example/dappvpn.client.config.json \
   ./bin/dapp_openvpn/dappvpn.client.config.json

# change log location to `./openvpn_server`
sed -i.bu \
    's/\/var/.\/openvpn_server/g' \
    ./bin/dapp_openvpn/dappvpn.agent.config.json

# change log location to `./openvpn_client`
sed -i.bu \
    's/\/var/.\/openvpn_client/g' \
    ./bin/dapp_openvpn/dappvpn.client.config.json


# change open_vpn location to `./openvpn_server`
sed -i.bu \
    's/\/etc\/openvpn/.\/openvpn_server/g' \
    ./bin/dapp_openvpn/dappvpn.agent.config.json
# change open_vpn location to `./openvpn_client`
sed -i.bu \
    's/\/etc\/openvpn/.\/openvpn_client/g' \
    ./bin/dapp_openvpn/dappvpn.client.config.json



# INSTALLER
cp ./openvpn_server/installer.agent.config.json \
   ./bin/openvpn_server/installer.config.json

cp ./openvpn_server/installer.client.config.json \
   ./bin/openvpn_client/installer.config.json




# DAPPCTRL

# AGENT
cp "${DAPPCTRL_DIR}"/dappctrl-dev.config.json \
    ./bin/dappctrl.agent.config.json

# change port to `${POSTGRES_PORT}`
sed -i.bu \
    's/"port":  *"[[:digit:]]*"/"port": "'${POSTGRES_PORT}'"/g' \
    ./bin/dappctrl.agent.config.json
# change log location to `./bin/log`
sed -i.bu \
    's/\/var\/log/.\/bin\/log/g' \
    ./bin/dappctrl.agent.config.json




# CLIENT
cp ./bin/dappctrl.agent.config.json \
   ./bin/dappctrl.client.config.json

# change role to `client`
sed -i.bu \
    's/"Role":  *"agent"/"Role": "client"/g' \
    ./bin/dappctrl.client.config.json