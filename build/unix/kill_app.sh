#!/usr/bin/env bash

cd `dirname $0`
. ./build.local.config

echo before:
ps

pkill -9 ${DAPP_OPENVPN}
pkill -9 ${DAPPCTRL}

echo
echo after:
ps