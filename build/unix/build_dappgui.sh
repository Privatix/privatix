#!/usr/bin/env bash

. ${1}

echo start dapp-gui build

cd "${DAPP_GUI_DIR}"

npm install
npm run build