#!/usr/bin/env bash
# Clear before install

install_dir="/opt/privatix_installer"
if [ -d "$install_dir" ]; then
      echo "Installation present, prepare for clean"
    cd /opt/privatix_installer || exit 1

    echo Removing ${1}...
    sudo ./dapp-installer remove -workdir /var/lib/container/${1}/ -role ${1}

    sudo rm -rf /opt/privatix_installer/
    sudo apt-get remove privatix -y
    sudo rm ~/Downloads/privatix*
else
     echo "Nothing to do"
fi