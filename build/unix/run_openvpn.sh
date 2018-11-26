#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

cd ${OPENVPN_AGENT_BIN}/bin/

if [[ ! -f "${OPENVPN_AGENT_BIN}"/config/server.conf ]]; then
    echo
    echo install openvpn_server
    sudo ./${OPENVPN_INST} install -config=../config/${INSTALLER_CONFIG}
fi


echo
echo start openvpn_server
sudo ./${OPENVPN_INST} start
