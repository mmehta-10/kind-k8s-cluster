## BYO AUTHN

Follow this guide to set up authentication to K8s clusters using LDAP backend. Components used - 

- `dex` used as OIDC provider 
- `OpenLDAP` for user management and source of truth for authentication 
- Either of `kubelogin` or `dex-k8s-authenticator` for getting token from OIDC provider after succesful authentication. This token will be used to access k8s API server. 

## Sources

- [Gloo: External auth with Dex example](https://docs.solo.io/gloo-gateway/2.1.x/observability/dashboard/auth/dex/)
- [Kubernetes Authentication and Authorization through Dex & LDAP and RBAC rules](https://medium.com/trendyol-tech/kubernetes-authentication-and-authorization-through-dex-ldap-and-rbac-rules-c2e03111b408)
- [Kubelogin Gtihub: Kubernetes OIDC authentication setup with kubelogin](https://github.com/int128/kubelogin/blob/master/docs/setup.md)
- [Dex Github: LDAP setup for dex](https://github.com/dexidp/dex/tree/master/examples/ldap)
- [Dex documentation: Authentication Through LDAP](https://dexidp.io/docs/connectors/ldap/#overview)

## Steps 

- Generate certs in `./ssl`

        ./01_gencerts.sh 

- Start LDAP server 

        ./ldap-start.sh


## Cleanup

- Destroy the setup
  
        ./cleanup.sh