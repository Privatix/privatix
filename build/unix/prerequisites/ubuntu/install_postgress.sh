#!/usr/bin/env bash

PG=$(apt-cache search '^postgresql\-[0-9]{1,2}\.[0-9]$' --names-only)
IFS=' '; pgpkg=($PG); unset IFS;
if [ -n "$pgpkg" ]; then
    echo "trying to install postgres: $pgpkg"
    #apt-get install $pgpkg -y
fi
if [ $? -eq 0 ]; then
    echo PGstatus=0
else
    echo "Error: PostgreSQL setup failed"
    PGstatus=1
fi
IFS='-'; pgver=($pgpkg); unset IFS;
if [[ ${pgver[1]} =~ ^[0-9]{1,2}\.[0-9]$ ]]
then
    pgold="/etc/postgresql/${pgver[1]}/main/pg_hba.conf.original"
    pgnew="/etc/postgresql/${pgver[1]}/main/pg_hba.conf"
    service postgresql stop &&
    cp $pgnew $pgold &&
    sed 's/local.*all.*postgres.*peer/local all postgres trust/' < $pgold > $pgnew &&
    sed 's/host.*all.*all.*127.0.0.1\/32.*md5/host all postgres 127.0.0.1\/32 trust/' < $pgold > $pgnew
fi
service postgresql start