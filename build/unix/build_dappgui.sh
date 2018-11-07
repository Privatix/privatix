#!/usr/bin/env bash

cd `dirname $0`
. ./build.config

echo start dapp-gui build

cd "${DAPP_GUI_DIR}"

npm install
npm run build