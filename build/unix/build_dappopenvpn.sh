#!/usr/bin/env bash

cd `dirname $0`
. ./build.config

export DAPP_OPENVPN_DIR

echo start dapp-openvpn build

cd "${DAPP_OPENVPN_DIR}"

"${DAPP_OPENVPN_DIR}"/scripts/build.sh
