variable "name" {
  description = "Name of the Compute Engine instance"
  type        = string
}
variable "zone" {
  description = "GCP Zone (e.g. us-central1-a)"
  type        = string
}
variable "machine_type" {
  description = "Machine type (e.g. e2-medium)"
  type        = string
}
variable "startup_script" {
  description = "Path to the DB startup script"
  type        = string
}
