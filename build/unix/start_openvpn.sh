#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

# CLIENT
echo
echo install openvpn_client
cd ${OPENVPN_CLIENT_BIN}/bin/
sudo ./${OPENVPN_INST} install -config=../${INSTALLER_CONFIG}

cd ${root_dir}
# SERVER
echo
echo install openvpn_server
cd ${OPENVPN_SERVER_BIN}/bin/
sudo ./${OPENVPN_INST} install -config=../${INSTALLER_CONFIG}

echo
echo start openvpn_server
sudo ./${OPENVPN_INST} start

sleep 5

echo
echo privatix daemons:
sudo launchctl list | grep privatix
sudo systemctl | grep privatix

echo
echo utun interfaces:
netstat -i | grep utun
