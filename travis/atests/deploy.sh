#!/bin/bash
# DOC - https://docs.privatix.network/support/install/cli-install-privatix-agent-node
### delete this block V
openssl aes-256-cbc -K $encrypted_b3625d5d910f_key -iv $encrypted_b3625d5d910f_iv \
    -in ${TRAVIS_BUILD_DIR}/travis/encrypted.zip.enc \
    -out ${TRAVIS_BUILD_DIR}/travis/encrypted.zip -d

unzip ${TRAVIS_BUILD_DIR}/travis/encrypted.zip \
      -d ${TRAVIS_BUILD_DIR}/travis/
### delete this block ^

cd "${TRAVIS_BUILD_DIR}/build/unix" || exit 1
. "./build.global.config"

git_branch_name=${GIT_BRANCH//[\/ -]/_}
config=${DAPPCTRL_CONFIG//[\/ -]/_}
network=${DAPP_GUI_NETWORK//[\/ -]/_}
force_update=${DAPP_INSTALLER_FORCE_UPDATE}

destination="$(date +%Y_%m_%d)-build${TRAVIS_BUILD_NUMBER}-${network}-${config}-${force_update}"

deploy_file="${TRAVIS_BUILD_DIR}/travis/encrypted/deploy.txt"
host=$(cat "${deploy_file}" | head -1)


url=http://${host}/travis/${git_branch_name}/${destination}/${VPN_UBUNTU_OUTPUT_DIR}privatix_ubuntu_x64_${VERSION_TO_SET_IN_BUILDER}_cli.deb
#url=http://artdev.privatix.net/travis/feature_fk_BV_1585/2019_09_10-build479-rinkeby-dappctrl_dev.config.json-0/vpn_ubuntu/privatix_ubuntu_x64_1.1.1_cli.deb

# Install

ssh stagevm@89.38.99.85 <<EOF
cd Downloads
wget -q ${url}
sudo dpkg -i privatix_ubuntu_x64_${VERSION_TO_SET_IN_BUILDER}_cli.deb
EOF
