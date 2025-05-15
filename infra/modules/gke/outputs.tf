output "endpoint" {
  description = "Kubernetes API endpoint"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}
