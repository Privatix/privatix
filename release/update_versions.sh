#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./release.local.config

cd ${DAPP_GUI_DIR}
git checkout release/${RELEASE_VERSION}
npm run update_versions