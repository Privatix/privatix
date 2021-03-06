#!/usr/bin/env bash
# Clear before install

install_dir="/opt/privatix_installer"
if [ -d "$install_dir" ]; then
    echo "Installation is present. Preparing for cleaning.."
    cd /opt/privatix_installer || exit 1

    echo Removing ${1}...
    sudo ./dapp-installer remove -workdir /var/lib/container/${1}/ -role ${1}

    sudo rm -rf /opt/privatix_installer/
    sudo apt-get remove privatix -y
    sudo rm ~/Downloads/privatix*
    if [ "${1}" == "client" ]; then
    echo "Remove supervisor on client"
    sudo /var/lib/container/dapp-supervisor remove
    fi
else
     echo "Nothing to do"
fi