#!/bin/sh

# Generate certs locally in ./ssl dir

BASEDIR=$(dirname $0)

rm -rf $BASEDIR/ssl

mkdir $BASEDIR/ssl

cat <<EOF >$BASEDIR/ssl/req.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = oidc.example.com
DNS.2 = oidc
DNS.3 = localhost
IP.1 = 127.0.0.1
EOF

openssl genrsa -out $BASEDIR/ssl/ca-key.pem 2048
openssl req -x509 -new -nodes -key $BASEDIR/ssl/ca-key.pem -days 10000 -out $BASEDIR/ssl/ca.pem -subj "/CN=kube-ca"

openssl genrsa -out $BASEDIR/ssl/key.pem 2048
openssl req -new -key $BASEDIR/ssl/key.pem -out $BASEDIR/ssl/csr.pem -subj "/CN=dex-cert" -config $BASEDIR/ssl/req.cnf
openssl x509 -req -in $BASEDIR/ssl/csr.pem -CA $BASEDIR/ssl/ca.pem -CAkey $BASEDIR/ssl/ca-key.pem -CAcreateserial -out $BASEDIR/ssl/cert.pem -days 10000 -extensions v3_req -extfile $BASEDIR/ssl/req.cnf
chmod a+r ./$BASEDIR/ssl/key.pem
