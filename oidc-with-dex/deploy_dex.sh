#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

docker run -p 5557:5557 -d --network=kind -v ${PWD}:/data:Z -v ${PWD}/ssl:/ssl:ro --name oidc ghcr.io/dexidp/dex:v2.31.0 dex serve /data/dex.yaml

echo $(docker inspect oidc -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}') oidc| sudo tee -a /etc/hosts

sleep 4

curl --cacert ssl/ca.pem https://oidc:5557/dex/.well-known/openid-configuration

kubectl oidc-login setup \
  --oidc-issuer-url=https://oidc:5557/dex \
  --oidc-client-id=kubernetes \
  --oidc-client-secret=ZXhhbXBsZS1hcHAtc2VjcmV0 \
  --certificate-authority=${PWD}/ssl/ca.pem \
  --oidc-extra-scope=email

# kubectl config set-credentials oidc \
#   --exec-api-version=client.authentication.k8s.io/v1beta1 \
#   --exec-command=kubectl \
#   --exec-arg=oidc-login \
#   --exec-arg=get-token \
#   --exec-arg=--oidc-issuer-url=https://oidc:5557/dex \
#   --exec-arg=--oidc-client-id=kubernetes \
#   --exec-arg=--oidc-client-secret=ZXhhbXBsZS1hcHAtc2VjcmV0