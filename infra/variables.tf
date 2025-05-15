variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region (e.g. us-central1)"
  type        = string
}

variable "zone" {
  description = "GCP Zone for VM (e.g. us-central1-a)"
  type        = string
}

variable "db_machine_type" {
  description = "Machine type for the DB VM"
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "Number of nodes in the GKE cluster"
  type        = number
  default     = 1
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-small"
}
