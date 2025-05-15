variable "name" {
  description = "Name of the GKE cluster"
  type        = string
}
variable "region" {
  description = "GCP region for the cluster"
  type        = string
}
variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
}
variable "node_type" {
  description = "Machine type for the GKE nodes (e.g. e2-small)"
  type        = string
}
