#!/usr/bin/env bash

. ${1}

echo copy binaries

# OPENVPN SERVER
cp -a ./openvpn_server/openvpn/ \
      ./bin/openvpn_server/bin/openvpn/

cp "${GOPATH}"/bin/openvpn-inst \
    ./bin/openvpn_server/bin/openvpn-inst

cp "${GOPATH}"/bin/dappvpn \
    ./bin/openvpn_server/bin/dappvpn

# OPENVPN CLIENT
cp -a ./bin/openvpn_server/ \
      ./bin/openvpn_client/


# DAPPCTRL
cp "${GOPATH}"/bin/dappctrl \
    ./bin/dappctrl

# DAPOPENPVPN
cp "${GOPATH}"/bin/dapp-openvpn-inst \
    ./bin/dapp_openvpn/dapp-openvpn-inst

cp "${GOPATH}"/bin/dappvpn \
    ./bin/dapp_openvpn/dappvpn
