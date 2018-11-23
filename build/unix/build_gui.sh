#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

echo
echo dapp-gui
echo

rm -rf ${DAPP_GUI_DIR}/build/

cd "${DAPP_GUI_DIR}"
npm install
npm run build