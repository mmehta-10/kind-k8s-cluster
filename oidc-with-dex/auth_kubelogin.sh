#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

kubectl oidc-login setup \
  --oidc-issuer-url=https://oidc:5557/dex \
  --oidc-client-id=kubernetes \
  --oidc-client-secret=SuperSecretSecret \
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
