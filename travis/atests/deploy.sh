#!/usr/bin/env bash
# DOC - https://docs.privatix.network/support/install/cli-install-privatix-agent-node

##
## add rsa for deploy
##
${TRAVIS_BUILD_DIR}/travis/atests/add_rsa.sh || exit 1

##
## clear vm's
##
ssh stagevm@89.38.99.85 'bash -s' < ${TRAVIS_BUILD_DIR}/travis/atests/clear.sh agent
ssh stagevm@89.38.99.127 -p 2222 'bash -s' < ${TRAVIS_BUILD_DIR}/travis/atests/clear.sh client

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


package_name=privatix_ubuntu_x64_${VERSION_TO_SET_IN_BUILDER}_cli.deb
url=http://${host}/travis/${git_branch_name}/${destination}/$(basename "${VPN_UBUNTU_OUTPUT_DIR}")/${package_name}

echo Package name: ${package_name}
#
# install an agent
#
echo
echo "Install Agent"
ssh stagevm@89.38.99.85 <<EOF || exit 1
cd ~/Downloads &&
wget -q ${url} &&
sudo dpkg -i ${package_name} &&
cd /opt/privatix_installer &&
sudo ./dapp-installer install -workdir /var/lib/container/agent/ -role agent  -source ./app.zip -torhsd var/lib/tor/hidden_service -torsocks 9099 -sendremote false &&
sudo sed -i 's/localhost:8888/0.0.0.0:8888/g' /var/lib/container/agent/dappctrl/dappctrl.config.json &&
sudo systemctl stop systemd-nspawn@agent.service &&
sudo systemctl start systemd-nspawn@agent.service || exit 1
EOF

#
# install a client
#
echo
echo "Install Client"
ssh stagevm@89.38.99.127 -p 2222 <<EOF || exit 1
cd ~/Downloads &&
wget -q ${url} &&
sudo dpkg -i $package_name &&
cd /opt/privatix_installer &&
sudo cp /opt/privatix_installer/dapp-supervisor /var/lib/container/ &&
sudo ./dapp-installer install -workdir /var/lib/container/client/ -role client  -source ./app.zip -torhsd var/lib/tor/hidden_service -torsocks 9099 -sendremote false &&
sudo sed -i 's/localhost:8888/0.0.0.0:8888/g' /var/lib/container/client/dappctrl/dappctrl.config.json || exit 1
EOF