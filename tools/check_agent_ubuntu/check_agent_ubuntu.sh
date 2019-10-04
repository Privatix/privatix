#!/usr/bin/env bash

if (( "$#" > 1 ));
then
    echo usage: check_agent_ubuntu.sh [privatix_app_folder_path]
    exit 1
fi

PRIVATIX_APP_FOLDER=${1:-/opt/Privatix}}


agent_checker=$(find "${PRIVATIX_APP_FOLDER}" -name "agent-checker" | head -1)
echo Agent checker:   $agent_checker

dappctrl_config=$(find "${PRIVATIX_APP_FOLDER}" -name "dappctrl.config.json" | head -1)
echo Dappctrl config: $dappctrl_config

openvpn_config=$(find "${PRIVATIX_APP_FOLDER}" -name "server.conf" | head -1)
echo Openvpn config: $openvpn_config

pay_port=$(cat "${dappctrl_config}" | \
        python3 -c 'import json,sys;j=json.load(sys.stdin);print(j["PayAddress"].split(":")[2].split("/")[0])';)
echo Pay port: $pay_port

openvpn_port=$(cat "${openvpn_config}" | grep -Eo "^port[ ]+[0-9]+" | grep -Eo "[0-9]+")
echo Openvpn port: $openvpn_port

echo && echo && echo
${agent_checker} -torhs tor/hidden_service -torsocks 9999 -payport ${pay_port} -ovpnport ${openvpn_port}