#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD

# Export vars for HELM repo and charts
set -a
source $BASEDIR/.env
set +a

# Add loki repos
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install promtail and loki (scalable, not distributed)
# Always start loki before launching promtail, otherwise promtail fails due to `connection refused` errors if started later

# # loki-distributed 
# helm upgrade --install $LOKI_RELEASE_NAME grafana/loki-distributed -f $BASEDIR/values/loki.yaml -n $APP_NAMESPACE
# loki-scalable 
helm upgrade --install $LOKI_RELEASE_NAME grafana/loki -f $BASEDIR/values/loki-scalable.yaml -n $APP_NAMESPACE
helm upgrade --install $PROMTAIL_RELEASE_NAME grafana/promtail -f $BASEDIR/values/promtail.yaml -n $APP_NAMESPACE


# helm upgrade --install loki grafana/loki-stack \
#     --create-namespace \
#     -n loki \
#     -f $BASEDIR/loki-values.yaml
