#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

# Start LDAP service on ports 389 and 636
docker-compose -f ../ldap/docker-compose.yaml up -d