

# Quick Start

## Start openldap
To start openldap inside a container

    docker run --name openldap -d -p 389:389 example/openldap:latest

To start a container with the ldap database and config stored in external volume
    
    docker run --name openldap -d -p 389:389 -v /data/slapd/database:/var/lib/ldap -v /data/slapd/config:/etc/ldap/slapd.d example/openldap:latest

To reset all the volume test data to original state and rebuild ldap image and restart container 

    ./rebuild-ldap.sh

## Test openldap
Query the database

    ldapsearch -x -H ldap://localhost -b dc=example,dc=com -D "cn=admin,dc=example,dc=com" -w Adm1n!

Test example specific queries

To query for the app profile info for app123

    ldapsearch -x -H ldap://localhost \
        -b ou=production,ou=applications,o=openapi,o=clients,dc=csso,dc=example,dc=com \
        -D "cn=admin,dc=example,dc=com" -w Adm1n! \
        "(cn=app123)"

To query which roles/groups that app123 belongs to

    ldapsearch -x -H ldap://localhost -b o=openapi,o=clients,dc=csso,dc=example,dc=com \
        -D "cn=admin,dc=example,dc=com" -w Adm1n! \
        "(&(objectclass=groupOfUniqueNames)(uniqueMember=cn=app123))" dn

To query which service types that app123 belongs to

    ldapsearch -x -H ldap://localhost -b "ou=service types,o=openapi,o=clients,dc=csso,dc=example,dc=com" \
        -D "cn=admin,dc=example,dc=com" -w Adm1n! \
        "(&(objectclass=groupOfUniqueNames)(uniqueMember=cn=app123))" dn

To query the cert for the mcCertificateAlias key 7288edd0fc3ffcbe93a0cf06e3568e28521687bc

    ldapsearch -x -H ldap://localhost -b ou=users,o=openapi,o=clients,dc=csso,dc=example,dc=com \
        -D "cn=admin,dc=example,dc=com" -w Adm1n! \
        "(mcCertificateAlias=7288edd0fc3ffcbe93a0cf06e3568e28521687bc)"

# Configuring LDAP

## Environment Variables
Environment variables defaults are set in **image/environment/default.yaml** and **image/environment/default.startup.yaml**.

See how to [set your own environment variables](#set-your-own-environment-variables)

### Default.yaml
Variables defined in this file are available at anytime in the container environment.

General container configuration:
- **LDAP_LOG_LEVEL**: Slap log level. defaults to  `256`. See table 5.1 in http://www.openldap.org/doc/admin24/slapdconf2.html for the available log levels.

### Default.startup.yaml
Variables defined in this file are only available during the container **first start** in **startup files**.
This file is deleted right after startup files are processed for the first time,
then all of these values will not be available in the container environment.

This helps to keep your container configuration secret. If you don't care all environment variables can be defined in **default.yaml** and everything will work fine.

Required and used for new ldap server only:
- **LDAP_ORGANISATION**: Organisation name. Defaults to `Example Inc.`
- **LDAP_DOMAIN**: Ldap domain. Defaults to `example.org`
- **LDAP_BASE_DN**: Ldap base DN. If empty automatically set from LDAP_DOMAIN value. Defaults to `(empty)`
- **LDAP_ADMIN_PASSWORD** Ldap Admin password. Defaults to `admin`
- **LDAP_CONFIG_PASSWORD** Ldap Config password. Defaults to `config`

- **LDAP_READONLY_USER** Add a read only user. Defaults to `false`
- **LDAP_READONLY_USER_USERNAME** Read only user username. Defaults to `readonly`
- **LDAP_READONLY_USER_PASSWORD** Read only user password. Defaults to `readonly`

Backend:
- **LDAP_BACKEND**: Ldap backend. Defaults to `hdb` (In comming versions v1.2.x default will be mdb)

	Help: http://www.openldap.org/doc/admin24/backends.html

TLS options:
- **LDAP_TLS**: Add openldap TLS capabilities. Can't be removed once set to true. Defaults to `true`.
- **LDAP_TLS_CRT_FILENAME**: Ldap ssl certificate filename. Defaults to `ldap.crt`
- **LDAP_TLS_KEY_FILENAME**: Ldap ssl certificate private key filename. Defaults to `ldap.key`
- **LDAP_TLS_CA_CRT_FILENAME**: Ldap ssl CA certificate  filename. Defaults to `ca.crt`
- **LDAP_TLS_ENFORCE**: Enforce TLS but except ldapi connections. Can't be disabled once set to true. Defaults to `false`.
- **LDAP_TLS_CIPHER_SUITE**: TLS cipher suite. Defaults to `SECURE256:+SECURE128:-VERS-TLS-ALL:+VERS-TLS1.2:-RSA:-DHE-DSS:-CAMELLIA-128-CBC:-CAMELLIA-256-CBC`, based on Red Hat's [TLS hardening guide](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/sec-Hardening_TLS_Configuration.html)
- **LDAP_TLS_VERIFY_CLIENT**: TLS verify client. Defaults to `demand`

	Help: http://www.openldap.org/doc/admin24/tls.html

Replication options:
- **LDAP_REPLICATION**: Add openldap replication capabilities. Defaults to `false`

- **LDAP_REPLICATION_CONFIG_SYNCPROV**: olcSyncRepl options used for the config database. Without **rid** and **provider** which are automatically added based on LDAP_REPLICATION_HOSTS.  Defaults to `binddn="cn=admin,cn=config" bindmethod=simple credentials=$LDAP_CONFIG_PASSWORD searchbase="cn=config" type=refreshAndPersist retry="60 +" timeout=1 starttls=critical`

- **LDAP_REPLICATION_DB_SYNCPROV**: olcSyncRepl options used for the database. Without **rid** and **provider** which are automatically added based on LDAP_REPLICATION_HOSTS.  Defaults to `binddn="cn=admin,$LDAP_BASE_DN" bindmethod=simple credentials=$LDAP_ADMIN_PASSWORD searchbase="$LDAP_BASE_DN" type=refreshAndPersist interval=00:00:00:10 retry="60 +" timeout=1 starttls=critical`

- **LDAP_REPLICATION_HOSTS**: list of replication hosts, must contain the current container hostname set by --hostname on docker run command. Defaults to :
	```yaml
	- ldap://ldap.example.org
  - ldap://ldap2.example.org
	```

	If you want to set this variable at docker run command add the tag `#PYTHON2BASH:` and convert the yaml in python:

		docker run --env LDAP_REPLICATION_HOSTS="#PYTHON2BASH:['ldap://ldap.example.org','ldap://ldap2.example.org']" --detach example/openldap:1.1.8

	To convert yaml to python online: http://yaml-online-parser.appspot.com/

Other environment variables:
- **LDAP_REMOVE_CONFIG_AFTER_SETUP**: delete config folder after setup. Defaults to `true`
- **LDAP_SSL_HELPER_PREFIX**: ssl-helper environment variables prefix. Defaults to `ldap`, ssl-helper first search config from LDAP_SSL_HELPER_* variables, before SSL_HELPER_* variables.


### Set your own environment variables

#### Use command line argument
Environment variables can be set by adding the --env argument in the command line, for example:

	docker run --env LDAP_ORGANISATION="My company" --env LDAP_DOMAIN="my-company.com" \
	--env LDAP_ADMIN_PASSWORD="JonSn0w" --detach example/openldap:1.1.8

Be aware that environment variable added in command line will be available at any time
in the container. In this example if someone manage to open a terminal in this container
he will be able to read the admin password in clear text from environment variables.

#### Link environment file

For example if your environment files **my-env.yaml** and **my-env.startup.yaml** are in /data/ldap/environment

	docker run --volume /data/ldap/environment:/container/environment/01-custom \
	--detach example/openldap:1.1.8

Take care to link your environment files folder to `/container/environment/XX-somedir` (with XX < 99 so they will be processed before default environment files) and not  directly to `/container/environment` because this directory contains predefined baseimage environment files to fix container environment (INITRD, LANG, LANGUAGE and LC_CTYPE).

Note: the container will try to delete the **\*.startup.yaml** file after the end of startup files so the file will also be deleted on the docker host. To prevent that : use --volume /data/ldap/environment:/container/environment/01-custom**:ro** or set all variables in **\*.yaml** file and don't use **\*.startup.yaml**:

	docker run --volume /data/ldap/environment/my-env.yaml:/container/environment/01-custom/env.yaml \
	--detach example/openldap:1.1.8

### Debug

The container default log level is **info**.
Available levels are: `none`, `error`, `warning`, `info`, `debug` and `trace`.

Example command to run the container in `debug` mode:

	docker run --detach example/openldap:1.1.8 --loglevel debug

See all command line options:

	docker run example/openldap:1.1.8 --help


### TLS

#### Use auto-generated certificate
By default, TLS is already configured and enabled, certificate is created using container hostname (it can be set by docker run --hostname option eg: ldap.example.org).

	docker run --hostname ldap.my-company.com --detach example/openldap:1.1.8

#### Use your own certificate

You can set your custom certificate at run time, by mounting a directory containing those files to **/container/service/slapd/assets/certs** and adjust their name with the following environment variables:

	docker run --hostname ldap.example.org --volume /path/to/certificates:/container/service/slapd/assets/certs \
        --env LDAP_TLS_CRT_FILENAME=my-ldap.crt \
        --env LDAP_TLS_KEY_FILENAME=my-ldap.key \
        --env LDAP_TLS_CA_CRT_FILENAME=the-ca.crt \
        --detach example/openldap:1.1.8

Other solutions are available please refer to the [Advanced User Guide](#advanced-user-guide)

#### Disable TLS
Add --env LDAP_TLS=false to the run command:

	docker run --env LDAP_TLS=false --detach example/openldap:1.1.8

### Multi master replication
Quick example, with the default config.

	#Create the first ldap server, save the container id in LDAP_CID and get its IP:
	LDAP_CID=$(docker run --hostname ldap.example.org --env LDAP_REPLICATION=true --detach example/openldap:1.1.8)
	LDAP_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $LDAP_CID)

	#Create the second ldap server, save the container id in LDAP2_CID and get its IP:
	LDAP2_CID=$(docker run --hostname ldap2.example.org --env LDAP_REPLICATION=true --detach example/openldap:1.1.8)
	LDAP2_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $LDAP2_CID)

	#Add the pair "ip hostname" to /etc/hosts on each containers,
	#beacause ldap.example.org and ldap2.example.org are fake hostnames
	docker exec $LDAP_CID bash -c "echo $LDAP2_IP ldap2.example.org >> /etc/hosts"
	docker exec $LDAP2_CID bash -c "echo $LDAP_IP ldap.example.org >> /etc/hosts"

That's it! But a little test to be sure:

Add a new user "billy" on the first ldap server

	docker exec $LDAP_CID ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin -f /container/service/slapd/assets/test/new-user.ldif -H ldap://ldap.example.org -ZZ

Search on the second ldap server, and billy should show up!

	docker exec $LDAP2_CID ldapsearch -x -H ldap://ldap2.example.org -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin -ZZ

	[...]

	# billy, example.org
	dn: uid=billy,dc=example,dc=org
	uid: billy
	cn: billy
	sn: 3
	objectClass: top
	objectClass: posixAccount
	objectClass: inetOrgPerson
	[...]



# Data persistence

The directories `/var/lib/ldap` (LDAP database files) and `/etc/ldap/slapd.d`  (LDAP config files) are used to persist the schema and data information, and should be mapped as volumes, so your ldap files are saved outside the container (see [Use an existing ldap database](#use-an-existing-ldap-database)). However it can be useful to not use volumes,
in case the image should be delivered complete with test data - this is especially useful when deriving other images from this one.

For more information about docker data volume, please refer to:

> [https://docs.docker.com/engine/tutorials/dockervolumes/](https://docs.docker.com/engine/tutorials/dockervolumes/)


## Edit your server configuration

Do not edit slapd.conf it's not used. To modify your server configuration use ldap utils: **ldapmodify / ldapadd / ldapdelete**

# Use an existing ldap database

This can be achieved by mounting host directories as volume.
Assuming you have a LDAP database on your docker host in the directory `/data/slapd/database`
and the corresponding LDAP config files on your docker host in the directory `/data/slapd/config`
simply mount this directories as a volume to `/var/lib/ldap` and `/etc/ldap/slapd.d`:

	docker run --volume /data/slapd/database:/var/lib/ldap \
        --volume /data/slapd/config:/etc/ldap/slapd.d \
        --detach example/openldap:latest

