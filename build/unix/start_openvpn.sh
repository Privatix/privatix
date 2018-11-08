#!/usr/bin/env bash

cd `dirname $0`
. ./build.local.config

# CLIENT
echo
echo install openvpn_client
cd ./bin/openvpn_client/bin/
sudo ./openvpn-inst install -config=../installer.config.json

# SERVER
echo
echo install openvpn_server
cd ../../openvpn_server/bin/
sudo ./openvpn-inst install -config=../installer.config.json

echo
echo start openvpn_server
sudo ./openvpn-inst start

sleep 5

echo
echo privatix daemons:
sudo launchctl list | grep privatix

echo
echo utun interfaces:
netstat -i | grep utun
