resource "google_cloudfunctions_function_iam_member" "public" {
  project        = var.project_id
  region         = var.region
  cloud_function = var.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
