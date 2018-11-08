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

echo
echo copy binaries
rsync -avzh ${DAPP_GUI_DIR}/build \
         ./bin/dapp_gui/

rsync -avzh ${DAPP_GUI_DIR}/node_modules \
         ./bin/dapp_gui/

cp -v ${DAPP_GUI_DIR}/package.json \
      ./bin/dapp_gui/package.json