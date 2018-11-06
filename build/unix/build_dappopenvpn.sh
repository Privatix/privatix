#!/usr/bin/env bash

. ${1}
export DAPP_OPENVPN_DIR

echo start dapp-openvpn build

cd "${DAPP_OPENVPN_DIR}"

"${DAPP_OPENVPN_DIR}"/scripts/build.sh
