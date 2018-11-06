#!/usr/bin/env bash

. ${1}

echo copy binaries

# OPENVPN
cp -a ./openvpn_server/openvpn/ \
      ./bin/openvpn_server/bin/openvpn/

# OPENVPN_INST
cp "${GOPATH}"/bin/openvpn-inst \
    ./bin/openvpn_server/bin/openvpn-inst

# DAPOPENPVPN
cp "${GOPATH}"/bin/dappvpn \
    ./bin/openvpn_server/bin/dappvpn

# DAPPCTRL
cp "${GOPATH}"/bin/dappctrl \
    ./bin/dappctrl

# DAPOPENPVPN_INST
cp "${GOPATH}"/bin/dapp-openvpn-inst \
    ./bin/dapp-openvpn-inst
