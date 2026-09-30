terraform {
  source = "../../../modules/kind-cluster"
}

inputs = {
  cluster_name    = "kind"
  kubeconfig_path = "~/.kube/config-kind"
  worker_port_mappings = [
    {
      container_port = 30080
      host_port      = 80
      protocol       = "TCP"
    },
    {
      container_port = 30443
      host_port      = 443
      protocol       = "TCP"
    },
    {
      container_port = 32090
      host_port      = 9000
      protocol       = "TCP"
    },
  ]

  worker_mounts = [
    {
      host_path      = "/Users/meghamehta/kind-labs/data/worker1"
      container_path = "/data"
      read_only      = false
    },
    {
      host_path      = "/Users/meghamehta/Documents/github"
      container_path = "/workspace"
      read_only      = false
    },
  ]
}
