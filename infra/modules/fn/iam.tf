resource "google_cloudfunctions_function_iam_member" "public" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"

  # ensure the function is created first
  depends_on = [
    google_cloudfunctions_function.function
  ]
}
