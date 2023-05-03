#!/bin/bash

set -eux
BASEDIR=$(dirname $0)
echo $BASEDIR
HOME_DIR=$PWD

# Start fake LDAP
# ../oidc-with-dex/01_gencerts.sh
# ../oidc-with-dex/02_ldap-start.sh

# Create symlink to ../oidc-with-dex/ssl dir, for next step
# ln -sf ../oidc-with-dex/ssl ssl

# Setup kind cluster with OIDC enabled
../oidc-with-dex/kind.sh start