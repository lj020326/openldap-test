#!/bin/bash

export LDAP_DATADIR=`pwd`/volumes
export IMAGE_ID="example/openldap"

docker run --name openldap -d -p 389:389 -p 636:636 -v $LDAP_DATADIR/slapd/database:/var/lib/ldap -v $LDAP_DATADIR/slapd/config:/etc/ldap/slapd.d $IMAGE_ID

docker logs -f openldap

