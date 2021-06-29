provider "google" {
  credentials = file("terraform-sa-key.json")
  project     = var.gcp_project_id
  region      = "us-central1"
}

data "google_storage_bucket_object" "archive" {
  name   = "${terraform.workspace}/index.zip"
  bucket = var.gcp_bucket
}

resource "google_cloudfunctions_function" "function" {
  name        = "function-test-${terraform.workspace}"
  description = "My function"
  runtime     = "python38"

  available_memory_mb   = 128
  source_archive_bucket = var.gcp_bucket
  source_archive_object = data.google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "hello_world"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}