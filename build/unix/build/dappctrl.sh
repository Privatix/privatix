#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.global.config

echo -----------------------------------------------------------------------
echo build dappctrl
echo -----------------------------------------------------------------------

"${DAPPCTRL_DIR}/scripts/build.sh" || exit 1