#!/bin/bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.global.config

echo -----------------------------------------------------------------------
echo create container
echo -----------------------------------------------------------------------


container_name="privatix-dapp-container"
echo "Container name:" ${container_name}

container_location="${PACKAGE_BIN_LINUX}/${container_name}"
echo "Container location:" ${container_location}

dappcoredir="${PACKAGE_BIN_LINUX}/app"
echo "App folder path:" ${dappcoredir}

# create container
sudo debootstrap stretch "${container_location}" http://deb.debian.org/debian
#sudo chroot ${container} dpkg --print-architecture

# copy dappcore
sudo cp -R ${dappcoredir}/. "${container_location}/"

# connect to container
sudo systemd-nspawn -D ${container_location}/ << EOF

#set root password: xHd26ksN
echo -e "xHd26ksN\nxHd26ksN\n" | passwd

echo "pts/0" >> /etc/securetty
echo deb http://deb.debian.org/debian stretch-backports main > /etc/apt/sources.list.d/stretch-backports.list

apt-get update
apt-get -t stretch-backports install -y systemd
apt-get install -y dbus net-tools

# install locale
apt-get install -y locales

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

# install postgres
apt-get update
apt-get install -y ca-certificates

echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install -y postgresql-10

# configure postgres
service postgresql stop
sed -i.bup 's/port = 5432/port = 5433/g' /etc/postgresql/10/main/postgresql.conf
sed -i.bup 's/local.*all.*postgres.*peer/local all postgres trust/g' /etc/postgresql/10/main/pg_hba.conf
sed -i.buh 's/host.*all.*all.*127.0.0.1\/32.*md5/host all postgres 127.0.0.1\/32 trust/g' /etc/postgresql/10/main/pg_hba.conf
service postgresql start

# install Tor
apt-get install -y tor
service tor stop
sed -i.bup 's/AppArmorProfile=system_tor/AppArmorProfile=/g' /lib/systemd/system/tor@default.service
systemctl daemon-reload
service tor start

# enable dappctrl daemon
mv /dappctrl/dappctrl.service /lib/systemd/system/
systemctl enable dappctrl.service

rm -rf /usr/share/doc/*
find /usr/share/locale -maxdepth 1 -mindepth 1 ! -name en_US -exec rm -rf {} \;
find /usr/share/i18n/locales -maxdepth 1 -mindepth 1 ! -name en_US -exec rm -rf {} \;
rm -rf /usr/share/man/*
rm -rf /usr/share/groff/*
rm -rf /usr/share/info/*
rm -rf /usr/share/lintian/*
rm -rf /usr/include/*

logout
EOF

echo create tar archive...
sudo tar cpJf "${PACKAGE_BIN_LINUX}/app.tar.xz" --exclude="./var/cache/apt/archives/*.deb" \
--exclude="./var/lib/apt/lists/*" --exclude="./var/cache/apt/*.bin" \
--one-file-system -C ${container_location} .

