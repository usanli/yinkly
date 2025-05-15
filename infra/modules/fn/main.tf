data "archive_file" "function_zip" {
  type        = "zip"
  # move up one level (from infra/) into the repo root, then into app/functions
  source_dir  = "${path.root}/../app/functions"
  output_path = "${path.module}/function.zip"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "fn_bucket" {
  name     = "${var.name}-bucket-${random_id.suffix.hex}"
  location = var.region
}

resource "google_storage_bucket_object" "fn_object" {
  name   = "${var.name}.zip"
  bucket = google_storage_bucket.fn_bucket.name
  source = data.archive_file.function_zip.output_path
}

resource "google_cloudfunctions_function" "function" {
  name                         = var.name
  runtime                      = var.runtime
  entry_point                  = var.entry_point
  trigger_http                 = var.trigger_http
  source_archive_bucket        = google_storage_bucket.fn_bucket.name
  source_archive_object        = google_storage_bucket_object.fn_object.name
  https_trigger_security_level = "SECURE_ALWAYS"
}
