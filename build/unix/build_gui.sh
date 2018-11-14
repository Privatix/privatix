#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

echo
echo dapp-gui
cd "${DAPP_GUI_DIR}"

# build
echo
echo build start
rm -rf ${DAPP_GUI_DIR}/build/
npm install
npm run build