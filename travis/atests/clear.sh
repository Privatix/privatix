#!/bin/bash
# Clear before install
install_dir="/opt/privatix_installer"
if [ -d "$install_dir" ]; then
	echo "Installation present, prepare for clean"
    cd /opt/privatix_installer &&
    ./remove.sh &&
    rm /opt/privatix_installer/*
    sudo apt-get remove privatix -y
else
 	echo "Nothing to do"
fi
