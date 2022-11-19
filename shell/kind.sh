#!/bin/bash

set -eux

BASEDIR=$(dirname $0)
echo $BASEDIR

HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

# mandatory scripts
# find ./terragrunt/live  -type f -name terragrunt-debug.tfvars.json -exec rm {} +

  case $1 in
	start)
            # Run Init 
            kind create cluster --config $HOME_DIR/kind-config.yaml || true
            kubectl cluster-info --context kind-kind

            ;;
	delete)
            # Run Init for a single component directory
            kind delete cluster

            ;;
	*)
		echo "Sorry, I don't understand"
		;;
  esac