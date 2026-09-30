variable "cluster_name" {
  description = "Name of the Kind cluster."
  type        = string
  default     = "kind"
}

variable "node_image" {
  description = "Optional Kind node image, for pinning the Kubernetes version."
  type        = string
  default     = null
}

variable "kubeconfig_path" {
  description = "Local path where the provider writes the cluster kubeconfig. Tilde expansion is supported."
  type        = string
  default     = "~/.kube/config-kind"
}

variable "worker_port_mappings" {
  description = "Host ports forwarded to ports on the worker node."
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = optional(string, "TCP")
    listen_address = optional(string, "0.0.0.0")
  }))
  default = [
    { container_port = 30080, host_port = 80 },
    { container_port = 30443, host_port = 443 },
    { container_port = 32090, host_port = 9000 },
  ]
}

variable "worker_mounts" {
  description = "Optional host directory mounts for the worker node. Supply machine-specific host paths in the Terragrunt environment configuration."
  type = list(object({
    host_path      = string
    container_path = string
    read_only      = optional(bool, false)
  }))
  default = []
}
