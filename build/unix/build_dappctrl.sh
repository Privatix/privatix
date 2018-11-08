#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.config

export DAPPCTRL_DIR

echo
echo dappctrl
cd "${DAPP_CTRL_DIR}"

# build
echo
echo build start
"${DAPPCTRL_DIR}"/scripts/build.sh

# binaries
cd ${root_dir}

echo
echo copy binaries
cp -v "${GOPATH}"/bin/dappctrl \
    ./bin/dappctrl

# configs
echo
echo copy and patch configs

echo
echo agent
cp -v "${DAPPCTRL_DIR}"/"${DAPPCTRL_CONFIG}" \
    ./bin/dappctrl.agent.config.json

# change port to `${POSTGRES_PORT}`
sed -i.bu \
    's/"port":  *"[[:digit:]]*"/"port": "'${POSTGRES_PORT}'"/g' \
    ./bin/dappctrl.agent.config.json
# change log location to `./bin/log`
sed -i.bu \
    's/\/var\/log/.\/bin\/log/g' \
    ./bin/dappctrl.agent.config.json

echo
echo dappctrl.agent.config.json
diff ./bin/dappctrl.agent.config.json.bu \
     ./bin/dappctrl.agent.config.json

echo
echo client
cp -v ./bin/dappctrl.agent.config.json \
   ./bin/dappctrl.client.config.json

# change role to `client`
sed -i.bu \
    's/"Role":  *"agent"/"Role": "client"/g' \
    ./bin/dappctrl.client.config.json

echo
echo dappctrl.client.config.json
diff ./bin/dappctrl.client.config.json.bu \
     ./bin/dappctrl.client.config.json