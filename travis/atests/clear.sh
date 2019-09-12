#!/bin/bash
# Clear before install

agent="sudo ./dapp-installer remove -workdir /var/lib/container/agent/ -role agent"
client="sudo ./dapp-installer remove -workdir /var/lib/container/client/ -role client"

install_dir="/opt/privatix_installer"
if [ -d "$install_dir" ]; then
	echo "Installation present, prepare for clean"
    cd /opt/privatix_installer &&

    if [ "$1" == "agent" ]; then
    echo "DEL AGENT"
    $agent
    fi
    if [ "$1" == "client" ]; then
    echo "DEL CLIENT"
    $client
    fi

    sudo rm -rf /opt/privatix_installer/
    sudo apt-get remove privatix -y
    sudo rm ~/Downloads/privatix*
else
 	echo "Nothing to do"
fi
