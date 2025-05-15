resource "google_compute_instance" "db" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  metadata_startup_script = var.startup_script

  network_interface {
    network       = "default"
    access_config {}  // gives it an external IP
  }

  tags = ["yinkly-db"]
}
