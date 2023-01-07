#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

  case $1 in
	start)
            # Create a kind cluster
            kind create cluster --config $HOME_DIR/kind-config.yaml || true
            kubectl cluster-info --context kind-kind

            # Create ingress
            kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

            kubectl wait --namespace ingress-nginx \
          --for=condition=ready pod \
          --selector=app.kubernetes.io/component=controller \
          --timeout=90s
            ;;
  apply) 
            kubectl apply -f $HOME_DIR/test-ing.yaml
            ;;
	delete)
            # Run Init for a single component directory
            kind delete cluster

            ;;
	*)
		echo "Sorry, I don't understand"
		;;
  esac