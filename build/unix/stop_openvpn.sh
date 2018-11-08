#!/usr/bin/env bash

cd `dirname $0`
. ./build.local.config

echo
echo remove openvpn_client
cd ./bin/openvpn_client/bin/
sudo ./openvpn-inst remove -workdir=..


echo
echo stop openvpn_server
cd ../../openvpn_server/bin
sudo ./openvpn-inst stop -workdir=..

echo
echo remove openvpn_server
sudo ./openvpn-inst remove -workdir=..

sleep 5

echo
echo privatix daemons:
sudo launchctl list | grep privatix

echo
echo utun interfaces:
netstat -i | grep utun