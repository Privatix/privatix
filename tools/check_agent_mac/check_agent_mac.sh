#!/usr/bin/env bash

if (( "$#" > 1 ));
then
    echo usage: check_agent_mac.sh [privatix_app_folder_path]
    exit 1
fi

PRIVATIX_APP_FOLDER=${1:-/Applications/Privatix}


agent_checker=$(find "${PRIVATIX_APP_FOLDER}" -name "agent-checker" -not -path "*/*.old/*" | head -1)
echo Agent checker: "${agent_checker}"

dappctrl_config=$(find "${PRIVATIX_APP_FOLDER}" -name "dappctrl.config.json" -not -path "*/*.old/*" | head -1)
echo Dappctrl config: "${dappctrl_config}"

openvpn_config=$(find "${PRIVATIX_APP_FOLDER}" -name "server.conf" -not -path "*/*.old/*" | head -1)
echo Openvpn config: "${openvpn_config}"

hidden_service=$(find "${PRIVATIX_APP_FOLDER}" -name "hidden_service" -not -path "*/*.old/*")
echo Hidden service: "${hidden_service}"
echo


pay_port=$(python -c 'import json,sys;j=json.load(sys.stdin);print j["PayAddress"].split(":")[2].split("/")[0]' \
           < "${dappctrl_config}")
echo Pay port: "${pay_port}"

openvpn_port=$(grep -Eo "^port[ ]+[0-9]+" "${openvpn_config}" | grep -Eo "[0-9]+")
echo Openvpn port: "${openvpn_port}"

torhs=$(cat "$hidden_service/hostname")
echo Torhs: "${torhs}"

torsocks=$(python -c 'import json,sys;j=json.load(sys.stdin);print j["TorSocksListener"];' \
           < "${dappctrl_config}")
echo Torsocks: "${torsocks}"

echo && echo && echo
set -x
${agent_checker} -torhs "${torhs}" -torsocks "${torsocks}" -payport "${pay_port}" -ovpnport "${openvpn_port}"