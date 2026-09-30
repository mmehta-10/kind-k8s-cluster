output "cluster_name" {
  description = "Name of the created Kind cluster."
  value       = kind_cluster.this.name
}

output "kubeconfig_path" {
  description = "Path to the generated kubeconfig file."
  value       = kind_cluster.this.kubeconfig_path
}

output "kubeconfig" {
  description = "Generated kubeconfig content. Treat as a secret."
  value       = kind_cluster.this.kubeconfig
  sensitive   = true
}

output "endpoint" {
  description = "Kubernetes API server endpoint."
  value       = kind_cluster.this.endpoint
}
