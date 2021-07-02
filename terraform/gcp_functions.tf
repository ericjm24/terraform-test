data "google_storage_bucket_object" "archive" {
  name   = "${terraform.workspace}/lib.zip"
  bucket = var.gcs_bucket
}

resource "google_cloudfunctions_function" "function" {
  for_each = toset(var.gcp_function_list)
  name        = each.value
  description = "My function"
  runtime     = "python38"

  available_memory_mb   = 128
  source_archive_bucket = var.gcs_bucket
  source_archive_object = data.google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = each.value
}