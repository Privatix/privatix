#!/usr/bin/env bash

root_dir=$(cd `dirname $0` && pwd)
cd ${root_dir}
. ./build.config

export DAPP_OPENVPN_DIR

echo
echo dapp-openvpn
cd "${DAPP_OPENVPN_DIR}"

# build
echo
echo build start
"${DAPP_OPENVPN_DIR}"/scripts/build.sh

# binaries
cd ${root_dir}

echo
echo copy binaries

cp -v "${GOPATH}"/bin/dapp-openvpn-inst \
      ./bin/dapp_openvpn/dapp-openvpn-inst

cp -v "${GOPATH}"/bin/dappvpn \
      ./bin/dapp_openvpn/dappvpn

# configs
echo
echo copy configs

cp -av "${DAPP_OPENVPN_DIR}"/files/example/products \
       ./bin/dapp_openvpn/products

cp -av "${DAPP_OPENVPN_DIR}"/files/example/templates \
       ./bin/dapp_openvpn/templates

cp -v "${DAPP_OPENVPN_DIR}"/files/example/dappvpn.agent.config.json \
      ./bin/dapp_openvpn/dappvpn.agent.config.json

cp -v "${DAPP_OPENVPN_DIR}"/files/example/dappvpn.client.config.json \
      ./bin/dapp_openvpn/dappvpn.client.config.json


# patch
echo
echo patch configs
# change log location to `./openvpn_server`
sed -i.bu \
    's/\/var/.\/bin\/openvpn_server/g' \
    ./bin/dapp_openvpn/dappvpn.agent.config.json

# change log location to `./openvpn_client`
sed -i.bu \
    's/\/var/.\/bin\/openvpn_client/g' \
    ./bin/dapp_openvpn/dappvpn.client.config.json


# change open_vpn location to `./openvpn_server`
sed -i.bu \
    's/\/etc\/openvpn/.\/bin\/openvpn_server/g' \
    ./bin/dapp_openvpn/dappvpn.agent.config.json
# change open_vpn location to `./openvpn_client`
sed -i.bu \
    's/\/etc\/openvpn/.\/bin\/openvpn_client/g' \
    ./bin/dapp_openvpn/dappvpn.client.config.json

echo
echo dappvpn.client.config.json
diff ./bin/dapp_openvpn/dappvpn.client.config.json.bu \
     ./bin/dapp_openvpn/dappvpn.client.config.json

echo
echo dappvpn.agent.config.json
diff ./bin/dapp_openvpn/dappvpn.agent.config.json.bu \
     ./bin/dapp_openvpn/dappvpn.agent.config.json