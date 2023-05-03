#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD

# Export vars for HELM repo and charts
set -a
source $BASEDIR/.env
set +a

# Delete helm releases
helm delete $LOKI_RELEASE_NAME -n $APP_NAMESPACE || true
helm delete $PROMTAIL_RELEASE_NAME -n $APP_NAMESPACE || true
helm delete $KUBE_PROM_RELEASE_NAME -n $APP_NAMESPACE || true
