#!/usr/bin/env bash

../git/git_checkout.sh ${1}

./build_backend.sh ${1}
./build_gui.sh ${1}

echo Copy openvpn
cp -a ./openvpn_server/openvpn/ ./openvpn_server/bin/openvpn/

echo Copy dappvpn and openvpn-inst binaries
cp "${GOPATH}"/bin/openvpn-inst ./openvpn_server/bin/openvpn-inst
cp "${GOPATH}"/bin/dappvpn ./openvpn_server/bin/dappvpn