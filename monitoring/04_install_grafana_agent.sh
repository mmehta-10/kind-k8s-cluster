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

# Install grafana agent
helm upgrade --install $GRAFANA_AGENT_RELEASE_NAME grafana/grafana-agent-operator -f $BASEDIR/values/grafana-agent.yaml -n $APP_NAMESPACE

# Create grafana agent configurations 
kubectl apply -f $BASEDIR/kube-events/