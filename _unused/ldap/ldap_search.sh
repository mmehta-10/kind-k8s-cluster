#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

# SEARCH_BASE="ou=People,dc=example,dc=org"
# SEARCH_SCOPE='cn=megha' # worked

SEARCH_BASE="ou=Groups,dc=example,dc=org"
SEARCH_SCOPE='cn=developers' # worked

docker exec -it ldap_ldap_1 \
  ldapsearch -x -D "cn=admin,dc=example,dc=org" -w admin \
  -b $SEARCH_BASE \
  -s sub ${SEARCH_SCOPE}

# -xLLL ldap://localhost:389
