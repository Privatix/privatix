#!/usr/bin/env bash

. ${1}

cd ${DAPP_GUI_DIR}
git checkout release/${RELEASE_VERSION}
echo npm run update_versions


cd ${DAPP_CTRL_DIR}
git checkout release/${RELEASE_VERSION}
echo python ${DAPP_CTRL_DIR}/scripts/update_versions/update_versions.py