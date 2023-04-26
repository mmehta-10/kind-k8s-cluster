#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD

GRAFANA_RELEASE_NAME=grafana-test
PROMETHEUS_RELEASE_NAME=prometheus

# Install Grafana
helm delete $GRAFANA_RELEASE_NAME \
    -n grafana || true 


helm delete $PROMETHEUS_RELEASE_NAME \
    -n prometheus-namespace
    