variable "name" {
  description = "Cloud Function name"
  type        = string
}
variable "runtime" {
  description = "Function runtime (e.g. nodejs18)"
  type        = string
}
variable "entry_point" {
  description = "Exported function entry point"
  type        = string
}
variable "trigger_http" {
  description = "Whether to enable HTTP trigger"
  type        = bool
}
variable "region" {
  description = "GCP region for the Cloud Function and bucket"
  type        = string
}

variable "project_id" {
  description = "GCP project ID (for IAM binding)"
  type        = string
}
