#!/usr/bin/env bash

echo Copy openvpn distributive
cp -a ./openvpn_server/openvpn/ ./openvpn_server/bin/openvpn/

echo Copy dappvpn and openvpn-inst binaries
cp "${GOPATH}"/bin/openvpn-inst ./openvpn_server/bin/openvpn-inst
cp "${GOPATH}"/bin/dappvpn ./openvpn_server/bin/dappvpn