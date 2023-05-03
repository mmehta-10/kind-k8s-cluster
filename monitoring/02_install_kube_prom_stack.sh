#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD

# Export vars for HELM repo and charts
set -a
source $BASEDIR/.env
set +a

# App and update repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install chart
helm upgrade --install $KUBE_PROM_RELEASE_NAME \
    prometheus-community/kube-prometheus-stack \
    -n $APP_NAMESPACE \
    --create-namespace \
    -f $BASEDIR/values-kube-prometheus-stack.yaml
