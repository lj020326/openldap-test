#!/bin/bash

#export LDAP_DATADIR=/data
#export LDAP_DATADIR=`pwd`/data
export LDAP_DATADIR=`pwd`/volumes
export IMAGE_NAME="example/openldap"
export IMAGE_TAG="1.1.9"
export IMAGE_ID="${IMAGE_NAME}:${IMAGE_TAG}"


function reset_ldap_data () {
	rm -fr ${LDAP_DATADIR}/slapd/ldap/*
	rm -fr ${LDAP_DATADIR}/slapd/config/*
	rm -fr ${LDAP_DATADIR}/slapd/database/*

	echo "ldap data reset!"
	return 0
}

function start_ldap () {

	cmd="docker run --name openldap -d -p 389:389 -p 636:636"
	cmd="${cmd} -e SLAPD_ADDITIONAL_MODULES=memberof"
	cmd="${cmd} -v ${LDAP_DATADIR}/slapd/database:/var/lib/ldap"
	cmd="${cmd} -v ${LDAP_DATADIR}/slapd/config:/etc/ldap/slapd.d"
	cmd="${cmd} ${IMAGE_ID}"

	echo "cmd=${cmd}"

#	res=$(eval $cmd)
	res=`$cmd`
	echo "result=$res"

	return 0
}

if [[ (! -d "$LDAP_DATADIR") || (! -d "$LDAP_DATADIR/slapd") ]]; then
    echo "creating directory $LDAP_DATADIR"
    mkdir -p $LDAP_DATADIR
    mkdir -p $LDAP_DATADIR/slapd
    mkdir -p $LDAP_DATADIR/slapd/config
    mkdir -p $LDAP_DATADIR/slapd/database
    mkdir -p $LDAP_DATADIR/slapd/ldap
fi

echo "stopping openldap"
docker stop openldap

echo "removing openldap instance"
docker rm openldap

echo "resetting openldap config/database data"
reset_ldap_data

echo "removing containers using openldap image"
## ref: https://linuxconfig.org/remove-all-containners-based-on-docker-image-name
#docker images | grep "example/openldap" | awk '{print $1}' | xargs docker rm
docker ps -a | awk '{ print $1,$2 }' | grep $IMAGE_ID | awk '{print $1 }' | xargs -I {} docker rm {}

echo "building openldap image"
docker build -t ${IMAGE_ID} .

echo "starting openldap instance"
start_ldap

docker logs -f openldap

