output "db_vm_ip" {
  description = "External IP of the DB VM"
  value       = module.vm.public_ip
}

output "gke_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.gke.endpoint
}

output "redirect_url" {
  description = "URL of the Cloud Function redirect endpoint"
  value       = module.fn.url
}
