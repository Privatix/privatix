#!/usr/bin/env bash

cd `dirname $0`
. ./build.config

# CLIENT
echo install openvpn_client

cd ./bin/openvpn_client/bin/
sudo ./openvpn-inst install -config=../installer.config.json

# SERVER
echo install openvpn_server

cd ../../openvpn_server/bin/
sudo ./openvpn-inst install -config=../installer.config.json

echo start openvpn_server
sudo ./openvpn-inst start
