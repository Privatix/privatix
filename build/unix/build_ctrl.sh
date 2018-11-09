#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.local.config

export DAPPCTRL_DIR

echo
echo dappctrl
cd "${DAPP_CTRL_DIR}"

# build
echo
echo build start
"${DAPPCTRL_DIR}"/scripts/build.sh

# clear
rm -rf ${DAPPCTRL_BIN}
mkdir -p ${DAPPCTRL_BIN}
mkdir -p ${DAPPCTRL_LOG}

# binaries
cd ${root_dir}

echo
echo copy binaries
cp -v "${GOPATH}"/bin/${DAPPCTRL} \
       ${DAPPCTRL_BIN}/${DAPPCTRL}

# configs
echo
echo copy and patch configs

echo
echo agent
cp -v "${DAPPCTRL_DIR}"/${DAPPCTRL_CONFIG} \
       ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}

# change port to `${POSTGRES_PORT}`
sed -i.bu \
    's/"port":  *"[[:digit:]]*"/"port": "'${POSTGRES_PORT}'"/g' \
    ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}

# change log location to ${DAPPCTRL_LOG}
location=${DAPPCTRL_LOG//\//\\/}
sed -i.bu \
    "s/\/var\/log/${location}/g" \
    ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}

echo
echo ${DAPPCTRL_AGENT_CONFIG}
diff ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}.bu \
     ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG}

echo
echo client
cp -v   ${DAPPCTRL_BIN}/${DAPPCTRL_AGENT_CONFIG} \
        ${DAPPCTRL_BIN}/${DAPPCTRL_CLIENT_CONFIG}

# change role to `client`
sed -i.bu \
    's/"Role":  *"agent"/"Role": "client"/g' \
    ${DAPPCTRL_BIN}/${DAPPCTRL_CLIENT_CONFIG}

echo
echo ${DAPPCTRL_CLIENT_CONFIG}
diff ${DAPPCTRL_BIN}/${DAPPCTRL_CLIENT_CONFIG}.bu \
     ${DAPPCTRL_BIN}/${DAPPCTRL_CLIENT_CONFIG}