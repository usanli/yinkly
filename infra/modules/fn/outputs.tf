output "url" {
  description = "HTTPS trigger URL for the Cloud Function"
  value       = google_cloudfunctions_function.function.https_trigger_url
}