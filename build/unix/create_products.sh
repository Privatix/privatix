#!/usr/bin/env bash

. ${1}

./bin/dapp_openvpn/dapp-openvpn-inst \
 -rootdir=./bin/dapp_openvpn/ \
 -connstr="dbname=dappctrl host=localhost user=postgres \
  sslmode=disable port=${POSTGRES_PORT}" -setauth

echo copy dappvpn config
cp ./bin/dapp_openvpn/dappvpn.client.config.json \
   ./bin/openvpn_client/config/dappvpn.config.json

cp ./bin/dapp_openvpn/dappvpn.agent.config.json \
   ./bin/openvpn_server/config/dappvpn.config.json