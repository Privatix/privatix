#!/usr/bin/env bash

cd `dirname $0`
. ./build.config

export DAPPCTRL_DIR

echo start dappctrl build

cd "${DAPP_CTRL_DIR}"

"${DAPPCTRL_DIR}"/scripts/build.sh
