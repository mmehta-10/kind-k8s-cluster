#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD

LOKI_RELEASE_NAME=loki

# Add grafana
helm repo add grafana \
    https://grafana.github.io/helm-charts
helm repo update

# helm install $LOKI_RELEASE_NAME \
#     grafana/loki \
#     --create-namespace \
#     -n loki \
#     -f $BASEDIR/loki-values.yaml || true

# helm upgrade --install loki grafana/loki-stack \
#     --set grafana.enabled=true,prometheus.enabled=true,prometheus.alertmanager.persistentVolume.enabled=false,prometheus.server.persistentVolume.enabled=false,loki.persistence.enabled=true,loki.persistence.storageClassName=standard,loki.persistence.size=5Gi \
#     --create-namespace -n loki

helm upgrade --install loki grafana/loki-stack \
    --create-namespace \
    -n loki \
    -f $BASEDIR/loki-values.yaml
