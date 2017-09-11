#!/bin/sh

#export LDAP_DATADIR=/data
export LDAP_DATADIR=`pwd`/data

if [ ! -d "$LDAP_DATADIR" ]; then
    echo "creating directory $LDAP_DATADIR"
    mkdir $LDAP_DATADIR
fi

echo "stopping openldap"
docker stop openldap

echo "removing openldap instance"
docker rm openldap

echo "resetting openldap config/database data"
./reset-ldap-data.sh

echo "removing containger using openldap image"
docker images | grep "example/openldap" | awk '{print $1}' | xargs docker rm

echo "building openldap image"
docker build -t example/openldap .

echo "starting openldap instance"
./start-ldap.sh

