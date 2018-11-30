#!/usr/bin/env bash

cd `dirname $0`
. ./build.sealed.config

echo before:
ps
sudo ps

sudo pkill -9 ${DAPP_OPENVPN}
sudo pkill -9 ${OPEN_VPN}
pkill -9 ${DAPPCTRL}

echo
echo after:
ps
sudo ps