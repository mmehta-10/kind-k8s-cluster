#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

# Stop kind cluster
./$BASEDIR/simple/kind.sh delete