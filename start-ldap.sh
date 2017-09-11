#!/bin/sh

docker run --name openldap -d -p 389:389 -p 636:636 -v $LDAP_DATADIR/slapd/database:/var/lib/ldap -v $LDAP_DATADIR/slapd/config:/etc/ldap/slapd.d example/openldap:latest

docker logs -f openldap

