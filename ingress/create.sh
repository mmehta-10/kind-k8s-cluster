#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR

# HOME_DIR=$PWD # HOME_DIR=$(dirname `dirname $PWD`)

CONTAINER_IP=`docker container inspect kind-control-plane \
  --format '{{ .NetworkSettings.Networks.kind.IPAddress }}'`

HOST="yourdomain.com"

# For mac
# https://dustinspecker.com/posts/test-ingress-in-kind/#request-ingress-endpoint-from-host
docker run \
  --add-host $HOST:$CONTAINER_IP \
  --net kind \
  --rm \
  curlimages/curl:7.71.0 $HOST/foo -I


# For linux 
# FILE=/etc/hosts

# if ! grep -i $HOST $FILE; then
#   sudo -- sh -c -e "echo '"'x yourdomain.com'"' >> /etc/hosts";
#   # echo "x yourdomain.com" >> $FILE
# fi

# sudo sed -i "" "/$HOST/ s/.*/$CONTAINER_IP\t$HOST/g" $FILE

# # sed -i '' "2i192.241.xx.xx  venus.example.com venus" /tmp/hosts

# cat $FILE
