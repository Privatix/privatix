#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

echo
echo dappctrl
echo

clean(){
    rm "${GOPATH}"/bin/${DAPPCTRL}
    rm -rf ${DAPPCTRL_BIN}
    mkdir -p ${DAPPCTRL_BIN}
    mkdir -p ${DAPPCTRL_LOG}
}

build(){
    export DAPPCTRL_DIR

    "${DAPPCTRL_DIR}"/scripts/build.sh

    cp -v   "${GOPATH}"/bin/${DAPPCTRL} \
            ${DAPPCTRL_BIN}/${DAPPCTRL}
}

prepare_agent_config(){
    # configs
    cd ${root_dir}

    cp -v "${DAPPCTRL_DIR}"/${DAPPCTRL_CONFIG} \
           ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}

    cp -v "${DAPPCTRL_DIR}"/${DAPPCTRL_CONFIG} \
           ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}_source

    # change port to `${POSTGRES_PORT}`
    sed -i.b \
        's/"port":  *"[[:digit:]]*"/"port": "'${POSTGRES_PORT}'"/g' \
        ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}

    user_pass="\"user\": \"${POSTGRES_USER}\"\
${POSTGRES_PASSWORD:+, \"password\"=\"${POSTGRES_PASSWORD}\"}"

    # change user to `${POSTGRES_USER}`
    sed -i.b \
        's/"user":  *".*"/'"${user_pass}"'/g' \
        ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}

    # change log location to ${DAPPCTRL_LOG}
    location=${DAPPCTRL_LOG//\//\\/}
    sed -i.b \
        "s/\/var\/log/${location}/g" \
        ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}
}

prepare_client_config(){
    echo
    echo client
    cp -v   ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG} \
            ${DAPPCTRL_BIN}/${DAPPCTRL_CLIENT_CONFIG}

    cp -v   ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG} \
            ${DAPPCTRL_BIN}/${DAPPCTRL_CLIENT_CONFIG}_source

     # change role to `client`
    sed -i.b \
        's/"Role":  *"agent"/"Role": "client"/g' \
        ${DAPPCTRL_BIN}/${DAPPCTRL_CLIENT_CONFIG}
}

copy_inst_config(){
    cp -v   ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG} \
            ${DAPPCTRL_BIN}/dappctrl.config.json
}

print_diff(){
    echo
    echo ${DAPPCTRL_AGENT_CONFIG}
    diff ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}_source \
         ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}

    echo
    echo ${DAPPCTRL_CLIENT_CONFIG}
    diff ${DAPPCTRL_BIN}/${DAPPCTRL_CLIENT_CONFIG}_source \
         ${DAPPCTRL_BIN}/${DAPPCTRL_CLIENT_CONFIG}
}

remove_b(){
    find ${DAPPCTRL_BIN} -name '*.b' -delete
}

clean
build
prepare_agent_config
prepare_client_config
copy_inst_config
remove_b
print_diff


