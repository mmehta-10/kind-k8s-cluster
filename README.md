# kind-k8s-cluster
Setup for a k8s cluster using kind (k8s in docker)

## nginx-ingress

Only one service can use nginx-ingress at a time if using same path. Let's say two services listen on path /healthz. Then ingress can only work for one of the created services, not both.
