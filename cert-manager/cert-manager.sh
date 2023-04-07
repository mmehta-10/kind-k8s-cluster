#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

# kubectl create ns cert-manager
kubectl create namespace cert-manager \
    --dry-run=client -o yaml |
    kubectl apply -f -

# Get the manifest file
curl -L https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml >$BASEDIR/cert-manager.yaml

mv $BASEDIR/cert-manager.yaml \
    $BASEDIR/cert-manager-1.10.1.yaml

# Create cert-manager resources
kubectl apply -f \
    $BASEDIR/cert-manager-1.10.1.yaml
kubectl -n cert-manager get all

# Create issuer and certificate - based on https://medium.com/adg-vit/free-ssl-on-kubernetes-with-lets-encrypt-and-cert-manager-8a2466a611d9
kubectl apply -f \
    $BASEDIR/issuer.yaml

kubectl apply -f \
    $BASEDIR/certificate.yaml
