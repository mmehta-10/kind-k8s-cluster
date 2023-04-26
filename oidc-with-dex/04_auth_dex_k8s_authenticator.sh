#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

# Add and update Helm repo for fetching dex-k8s-authenticator
helm repo add \
  skm https://charts.sagikazarmark.dev

helm repo update

# Create nginx ingress controller
kubectl apply -f \
    https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait pods \
-n ingress-nginx \
-l app.kubernetes.io/component=controller \
--for condition=Ready \
--timeout=90s

# Init vars
KUBE_CONTEXT=kind-kind
KIND_IP=127.0.0.1
NAMESPACE=dex

# kind k8s API server cert
K8S_CA_PEM=$(  kubectl config view --minify --flatten -o json --context $KUBE_CONTEXT \
  | jq -r '.clusters[] | select(.name == '\"$KUBE_CONTEXT\"') | .cluster."certificate-authority-data"' | base64 -d | sed 's/^/        /')

# echo $K8S_CA_PEM

TRUSTED_ROOT_CA=$(cat $BASEDIR/ssl/ca.pem | sed 's/^/        /')

TRUSTED_ROOT_CA=$TRUSTED_ROOT_CA KIND_IP=$KIND_IP K8S_CA_PEM=$K8S_CA_PEM envsubst <$BASEDIR/dex-k8s-authenticator-override-values.yaml >$BASEDIR/values.yaml

helm upgrade \
  --install dex-k8s-authenticator \
  skm/dex-k8s-authenticator \
  --create-namespace \
  --namespace $NAMESPACE \
  --version 0.0.1 \
  --values $BASEDIR/values.yaml

until [ $(kubectl get ingress -n "${NAMESPACE}" | grep dex-k8s-authenticator | grep -o $KIND_IP | wc -l) -eq 1 ]; do
    echo "Waiting for ingress ..."
    sleep 3
done

rm -rf $BASEDIR/values.yaml

echo -e "\n Launch URL: http://dex-k8s-authenticator.127.0.0.1.nip.io/"
