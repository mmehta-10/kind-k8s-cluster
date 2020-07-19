# kind-k8s-cluster
Details for installation of a k8s cluster using kind (k8s in docker)

## Set up a cluster with three workers

`kind create cluster --config kind-config.yaml`

## nginx-ingress

As hostname can only be `localhost`, only one service can use nginx-ingress at a time, in case services have common path. Let's say two services listen on path /healthz. Then ingress can only work for one of the created services on `localhost/healthz`, not both.

> More details: https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx
