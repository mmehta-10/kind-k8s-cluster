#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

# Add and update Helm repo
helm repo add fairwinds-stable \
  https://charts.fairwinds.com/stable

helm repo update

# Install helm chart
helm install rbac-manager fairwinds-stable/rbac-manager \
  --namespace rbac-manager \
  --create-namespace

# # Create nginx ingrass controller
# kubectl apply -f \
#   https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
