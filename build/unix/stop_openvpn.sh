#!/usr/bin/env bash

cd ./bin/openvpn_client/bin/
echo remove openvpn_client
sudo ./openvpn-inst remove -workdir=..

cd ../../openvpn_server/bin

echo stop openvpn_server
sudo ./openvpn-inst stop -workdir=..

echo remove openvpn_server
sudo ./openvpn-inst remove -workdir=..
