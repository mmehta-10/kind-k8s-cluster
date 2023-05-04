#!/bin/bash

# We need this to collect and ship k8s events to loki sink
# See: https://www.cncf.io/blog/2023/03/13/how-to-use-kubernetes-events-for-effective-alerting-and-monitoring/ > Section "Grafana Agent and monitoring"
# This is slightly complex and subject to change on a real EKS cluster
# There were relatiively simpler solutions like eventrouter, but no longer actively developed (See: https://github.com/vmware-archive/eventrouter/issues/126)

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
