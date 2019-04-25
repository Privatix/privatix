#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.global.config

echo -----------------------------------------------------------------------
echo build dapp-proxy
echo -----------------------------------------------------------------------

"${DAPP_PROXY_DIR}/scripts/build.sh" || exit 1
