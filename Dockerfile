FROM osixia/openldap:1.1.8
MAINTAINER Your Name <your@name.com>

ADD bootstrap /container/service/slapd/assets/config/bootstrap
ADD certs /container/service/slapd/assets/certs
ADD environment /container/environment/01-custom