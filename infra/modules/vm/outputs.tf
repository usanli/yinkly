output "public_ip" {
  description = "The external IP address of the DB VM"
  value       = google_compute_instance.db.network_interface[0].access_config[0].nat_ip
}
