#!/bin/sh

# Generate certs locally in ./ssl dir

mkdir ssl

cat <<EOF >ssl/req.cnf
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

openssl genrsa -out ssl/ca-key.pem 2048
openssl req -x509 -new -nodes -key ssl/ca-key.pem -days 10000 -out ssl/ca.pem -subj "/CN=kube-ca"

openssl genrsa -out ssl/key.pem 2048
openssl req -new -key ssl/key.pem -out ssl/csr.pem -subj "/CN=dex-cert" -config ssl/req.cnf
openssl x509 -req -in ssl/csr.pem -CA ssl/ca.pem -CAkey ssl/ca-key.pem -CAcreateserial -out ssl/cert.pem -days 10000 -extensions v3_req -extfile ssl/req.cnf
chmod a+r ./ssl/key.pem