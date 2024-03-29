#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

KIND_CONFIG_FILE=$BASEDIR/kind-config.yaml

case $1 in
start)
  # Create a kind cluster
  kind create cluster --config $KIND_CONFIG_FILE || true
  kubectl cluster-info --context kind-kind
  ;;

apply)
  kubectl apply -f $HOME_DIR/test-ing.yaml
  ;;

delete)
  # Destroy kind cluster
  kind delete cluster
  ;;

*)
  echo "Sorry, I don't understand"
  ;;
esac
