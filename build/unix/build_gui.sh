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
npm install
npm run build

# binaries
cd ${root_dir}

# clear
rm -rf ${DAPP_GUI_BIN}
mkdir -p ${DAPP_GUI_BIN}

# copy
echo
echo copy binaries
rsync -avzh ${DAPP_GUI_DIR}/build/. \
            ${DAPP_GUI_BIN}/build

rsync -avzh ${DAPP_GUI_DIR}/node_modules/. \
            ${DAPP_GUI_BIN}/node_modules

cp -v ${DAPP_GUI_DIR}/package.json \
      ${DAPP_GUI_BIN}/package.json