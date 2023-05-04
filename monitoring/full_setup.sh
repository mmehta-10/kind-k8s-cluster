#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD

# Export vars for HELM repo and charts
set -a
source $BASEDIR/.env
set +a

# This will create the k8s cluster and install kube-prometheus-stack, loki and grafana-agent for collecting events logs
$BASEDIR/01_cluster_setup.sh
$BASEDIR/02_install_kube_prom_stack.sh
$BASEDIR/03_install_loki.sh
$BASEDIR/04_install_grafana_agent.sh
