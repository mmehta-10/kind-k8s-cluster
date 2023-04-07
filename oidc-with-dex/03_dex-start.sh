#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)
OIDC_PROVIDER_PORT=5557

# Start dex container as `oidc`
# Share network with kind cluster
# Mount volumes to access dex.yaml (for dex configuration) and ./ssl (for certs)
docker run -p $OIDC_PROVIDER_PORT:$OIDC_PROVIDER_PORT \
  -d --network=kind \
  -v ${PWD}:/data:Z \
  -v ${PWD}/ssl:/ssl:ro \
  --name oidc \
  ghcr.io/dexidp/dex:v2.31.0 \
  dex serve /data/dex.yaml

# Fetch oidc container IP
# add to /etc/hosts to resolve oidc on local browser
echo $(docker inspect oidc \-f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}') oidc |
  sudo tee -a /etc/hosts

# Wait for container to start
sleep 4

# Is container working
curl --cacert ssl/ca.pem \
  https://oidc:$OIDC_PROVIDER_PORT/dex/.well-known/openid-configuration
