resource "google_container_cluster" "primary" {
  name               = var.name
  location           = var.region
  initial_node_count = var.node_count

  node_config {
    machine_type = var.node_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
