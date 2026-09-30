# Infrastructure layout

- `modules/` contains reusable Terraform modules.
- `live/` contains Terragrunt environment and cluster configurations.
- `clusters/` contains cluster-specific configuration files consumed by the
  module. Keep host-specific values out of shared files where possible.

Use a separate Terragrunt leaf for each machine or cluster and point each leaf
at the shared module. The initial local cluster unit is in
`live/local/kind/terragrunt.hcl`. Keep state, caches, and local variable
overrides out of version control.
