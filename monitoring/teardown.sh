#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD

GRAFANA_RELEASE_NAME=grafana-test
PROMETHEUS_RELEASE_NAME=prometheus
LOKI_RELEASE_NAME=loki

# Delete Grafana
helm delete $GRAFANA_RELEASE_NAME \
    -n grafana || true

# Delete Grafana
helm delete $PROMETHEUS_RELEASE_NAME \
    -n prometheus-namespace || true

# Delete Loki
helm delete $LOKI_RELEASE_NAME \
    -n loki || true
