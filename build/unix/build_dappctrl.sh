#!/usr/bin/env bash

. ${1}

export DAPPCTRL_DIR

echo start dappctrl build

cd "${DAPP_CTRL_DIR}"

"${DAPPCTRL_DIR}"/scripts/build.sh
