#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

# Apply RBACdefinition
FILENAME=rbacdefinition-everything.yaml

case $1 in
create)
  # Create RBACdef
  kubectl apply -f $BASEDIR/$FILENAME

  # Confirm it's created
  kubectl get rbacdefinitions.rbacmanager.reactiveops.io rbac-def
  ;;

delete)
  kubectl delete -f $BASEDIR/$FILENAME
  ;;

*)
  echo "Sorry, I don't understand"
  ;;
esac
