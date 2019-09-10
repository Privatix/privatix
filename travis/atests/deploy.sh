#!/bin/bash

#echo -e "LOGIN ssh"
#ssh stagevm@89.38.99.85 hostname && wget http://ya.ru
#echo -e "LOGIN ssh"
#wget http://ya.ru/

#scp ./bin/vpn/ubuntu/linux-dapp-installer/app.tar.xz stagevm@89.38.99.85:~

ssh stagevm@89.38.99.85 <<EOF
mkdir test
cd test
wget http://ya.ru
EOF

