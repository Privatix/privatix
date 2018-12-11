#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.sealed.config


create_openvpn_configs(){
    cd ${OPENVPN_AGENT_BIN}/bin/

    if [[ ! -f "${OPENVPN_AGENT_BIN}"/config/server.conf ]]; then
        echo
        echo install openvpn_server
        sudo ./${OPENVPN_INST} install -config=../config/${INSTALLER_CONFIG}
    fi

    cd ${root_dir}
}

run_openvpn(){
    echo sudo ${OPENVPN_AGENT_BIN}/bin/${OPEN_VPN} ${OPENVPN_AGENT_BIN}/config/server.conf
    sudo ${OPENVPN_AGENT_BIN}/bin/${OPEN_VPN} ${OPENVPN_AGENT_BIN}/config/server.conf &
}

run_dappctrl(){
    echo run ${DAPPCTRL_BIN}/${DAPPCTRL}
    ${DAPPCTRL_BIN}/${DAPPCTRL} -config="${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}" &
}

run_adapter(){
    echo run ${OPENVPN_AGENT_BIN}/bin/${DAPP_OPENVPN}
    sudo ${OPENVPN_AGENT_BIN}/bin/${DAPP_OPENVPN} -config=${OPENVPN_AGENT_BIN}/config/${DAPP_VPN_CONFIG} &
}

run_gui(){
    echo run ${DAPP_GUI_BIN}
    cd ${DAPP_GUI_DIR}
    npm start &
}


create_openvpn_configs
run_openvpn
#sleep 5
#run_dappctrl
#sleep 3
#run_adapter
#sleep 5
#run_gui
