#!/usr/bin/env bash
# DOC - https://docs.privatix.network/support/install/cli-install-privatix-agent-node

##
## add rsa for deploy
##
${TRAVIS_BUILD_DIR}/travis/atests/add_rsa.sh

##
## clear vm's
##
ssh stagevm@89.38.99.85 'bash -s' < ${TRAVIS_BUILD_DIR}/travis/atests/clear.sh agent
ssh stagevm@89.38.99.176 'bash -s' < ${TRAVIS_BUILD_DIR}/travis/atests/clear.sh client

#
# calculate download link
#
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
pkg=$(echo $url | awk -F / '{print $8}')

#
# install an agent
#
echo "Install Agent"
ssh stagevm@89.38.99.85 <<EOF
cd Downloads
wget -q ${url}
sudo dpkg -i $pkg

cd /opt/privatix_installer 
./install.sh 

sudo sed -i 's/localhost:8888/0.0.0.0:8888/g' /var/lib/container/agent/dappctrl/dappctrl.config.json
sudo systemctl stop systemd-nspawn@agent.service
sudo systemctl start systemd-nspawn@agent.service
EOF

#
# install a client
#
echo "Install Client"
ssh stagevm@89.38.99.176 <<EOF
cd Downloads
wget -q ${url}
sudo dpkg -i $pkg

cd /opt/privatix_installer
sudo cp ./dapp-supervisor /var/lib/container/dapp-supervisor
sudo sed -i 's/agent/client/g' dapp-installer.config.json 
./install.sh 

sudo sed -i 's/localhost:8888/0.0.0.0:8888/g' /var/lib/container/client/dappctrl/dappctrl.config.json
EOF