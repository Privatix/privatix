#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

echo
echo remove openvpn_client
cd ${OPENVPN_CLIENT_BIN}/bin/
sudo ./${OPENVPN_INST} remove -workdir=..

cd ${root_dir}
echo
echo stop openvpn_server
cd ${OPENVPN_SERVER_BIN}/bin/
sudo ./${OPENVPN_INST} stop -workdir=..

echo
echo remove openvpn_server
sudo ./${OPENVPN_INST} remove -workdir=..

sleep 5

echo
echo privatix daemons:
sudo launchctl list | grep privatix
sudo systemctl | grep privatix

echo
echo utun interfaces:
netstat -i | grep utun