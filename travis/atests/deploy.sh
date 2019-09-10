#!/bin/bash

#echo -e "LOGIN ssh"
#ssh stagevm@89.38.99.85 hostname && wget http://ya.ru
#echo -e "LOGIN ssh"
#wget http://ya.ru/

#scp ./bin/vpn/ubuntu/linux-dapp-installer/app.tar.xz stagevm@89.38.99.85:~

###

git_branch_name=${GIT_BRANCH//[\/ -]/_}
config=${DAPPCTRL_CONFIG//[\/ -]/_}
network=${DAPP_GUI_NETWORK//[\/ -]/_}
force_update=${DAPP_INSTALLER_FORCE_UPDATE}

destination="$(date +%Y_%m_%d)-build${TRAVIS_BUILD_NUMBER}-${network}-${config}-${force_update}"

deploy_file="${TRAVIS_BUILD_DIR}/travis/encrypted/deploy.txt"
host=$(cat "${deploy_file}" | head -1)

url=https://${host}/travis/${git_branch_name}/${destination}/${VPN_UBUNTU_OUTPUT_DIR}/privatix_ubuntu_x64_${VERSION_TO_SET_IN_BUILDER}_cli.deb
echo ${url}
###

#ssh stagevm@89.38.99.85 <<EOF
#mkdir test
#cd test
#wget http://ya.ru
#EOF

