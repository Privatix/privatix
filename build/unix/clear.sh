#!/usr/bin/env bash

cd `dirname $0`

./kill_app.sh
./stop_openvpn.sh

rm -rf ./bin/

mkdir -p "./bin/log"
mkdir -p "./bin/dapp_gui"
mkdir -p "./bin/dapp_openvpn"

mkdir -p "./bin/openvpn_server/bin"
mkdir -p "./bin/openvpn_server/config"
mkdir -p "./bin/openvpn_server/log"

cp -a ./bin/openvpn_server/ \
      ./bin/openvpn_client/
