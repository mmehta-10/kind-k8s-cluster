# Kind cluster Terraform module

Creates and deletes a Kind cluster with the `tehcyx/kind` provider. The module
provides the existing two-node layout, HTTP/HTTPS and Traefik dashboard port
mappings, and optional worker host mounts. Cluster lifecycle changes require
recreating the cluster because the provider does not modify existing clusters.

The environment-specific inputs are in `infra/live/local/kind/terragrunt.hcl`.
Set `worker_mounts` there for host directories that should be mounted into the
worker; host paths are machine-specific and should not be copied blindly to
another machine.
