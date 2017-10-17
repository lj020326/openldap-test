FROM osixia/openldap:1.1.9
MAINTAINER LJ <lee.johnson@example.com>

ADD bootstrap /container/service/slapd/assets/config/bootstrap
ADD certs /container/service/slapd/assets/certs
ADD environment /container/environment/01-custom

EXPOSE 389
EXPOSE 636