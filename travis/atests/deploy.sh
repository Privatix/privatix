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


#url=http://${host}/travis/${git_branch_name}/${destination}/${VPN_UBUNTU_OUTPUT_DIR}privatix_ubuntu_x64_${VERSION_TO_SET_IN_BUILDER}_cli.deb
#url=http://artdev.privatix.net/travis/feature_fk_BV_1585/2019_09_10-build479-rinkeby-dappctrl_dev.config.json-0/vpn_ubuntu/privatix_ubuntu_x64_1.1.1_cli.deb
url=http://artdev.privatix.net/travis/develop/2019_09_12-build508-rinkeby-dappctrl_dev.config.json-1/vpn_ubuntu/privatix_ubuntu_x64_1.1.0_cli.deb

echo "Install Agent"
ssh stagevm@89.38.99.85 <<EOF
cd Downloads
wget -q ${url}
sudo dpkg -i privatix_ubuntu_x64_1.1.0_cli.deb

cd /opt/privatix_installer 
./install.sh 
sudo apt-get install python
sudo -H ./cli/install_dependencies.sh

sudo sed -i 's/localhost:8888/0.0.0.0:8888/g' /var/lib/container/agent/dappctrl/dappctrl.config.json
sudo systemctl stop systemd-nspawn@agent.service
sudo systemctl start systemd-nspawn@agent.service
EOF

echo "Install Client"
ssh stagevm@89.38.99.176 <<EOF
cd Downloads
wget -q ${url}
sudo dpkg -i privatix_ubuntu_x64_1.1.0_cli.deb

cd /opt/privatix_installer
cp ./dapp-supervisor /var/lib/container/
sudo sed -i 's/agent/client/g' dapp-installer.config.json 
./install.sh 
sudo apt-get install python
sudo -H ./cli/install_dependencies.sh

sudo sed -i 's/localhost:8888/0.0.0.0:8888/g' /var/lib/container/agent/dappctrl/dappctrl.config.json
sudo systemctl stop systemd-nspawn@agent.service
sudo systemctl start systemd-nspawn@agent.service
EOF