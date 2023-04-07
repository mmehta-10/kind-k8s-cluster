#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

# Stop LDAP container 
docker-compose -f ../ldap/docker-compose.yaml down

# Stop dex
./dex-stop.sh

# Stop kind cluster 
./kind.sh delete