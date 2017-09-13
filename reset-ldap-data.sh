#!/bin/sh


rm -fr $LDAP_DATADIR/slapd/ldap/*
rm -fr $LDAP_DATADIR/slapd/config/*
rm -fr $LDAP_DATADIR/slapd/database/*

echo "ldap data reset!"
