#!/usr/bin/env bash

cd `dirname $0`
. ./build.local.config

# install
echo
echo install products

./bin/dapp_openvpn/dapp-openvpn-inst \
 -rootdir=./bin/dapp_openvpn/ \
 -connstr="dbname=dappctrl host=localhost user=postgres \
  sslmode=disable port=${POSTGRES_PORT}" -setauth

# binaries
echo
echo copy binaries

# openvpn_server
cp -av ./openvpn_server/openvpn/ \
       ./bin/openvpn_server/bin/openvpn/

# openvpn & openssl
cp -v $(which openssl) \
      ./bin/openvpn_server/bin/openvpn/openssl

cp -v $(which openvpn) \
      ./bin/openvpn_server/bin/openvpn/openvpn

# openvpn-inst & dappvpn
cp -v "${GOPATH}"/bin/openvpn-inst \
      ./bin/openvpn_server/bin/openvpn-inst

cp -v "${GOPATH}"/bin/dappvpn \
      ./bin/openvpn_server/bin/dappvpn

# openvpn_client
cp -av ./bin/openvpn_server/ \
      ./bin/openvpn_client/

# configs
echo
echo copy configs
cp -v ./bin/dapp_openvpn/dappvpn.client.config.json \
      ./bin/openvpn_client/config/dappvpn.config.json

cp -v ./bin/dapp_openvpn/dappvpn.agent.config.json \
      ./bin/openvpn_server/config/dappvpn.config.json

cp -v ./openvpn_server/installer.agent.config.json \
      ./bin/openvpn_server/installer.config.json

cp -v ./openvpn_server/installer.client.config.json \
      ./bin/openvpn_client/installer.config.json
