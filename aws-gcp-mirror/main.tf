data "aws_s3_bucket" "vendor_s3_bucket" {
    bucket=var.s3_bucket_name
}

data "google_storage_transfer_project_service_account" "default" {
  project = var.project
}

resource "google_storage_bucket" "gcs-mirror" {
  name          = var.gcs_bucket_name
  storage_class = "NEARLINE"
  project       = var.project
}

resource "google_storage_bucket_iam_member" "gcs-mirror" {
  bucket     = google_storage_bucket.gcs-mirror.name
  role       = "roles/storage.admin"
  member     = "serviceAccount:${data.google_storage_transfer_project_service_account.default.email}"
  depends_on = [google_storage_bucket.gcs-mirror]
}

resource "google_storage_transfer_job" "s3-bucket-nightly-mirror" {
  description = "Nightly mirror of S3 bucket"
  project     = var.project

  transfer_spec {
    object_conditions {
      max_time_elapsed_since_last_modification = "600s"
      exclude_prefixes = [
        "requests.gz",
      ]
    }
    transfer_options {
      delete_objects_unique_in_sink = false
    }
    aws_s3_data_source {
      bucket_name = var.s3_bucket_name
      aws_access_key {
        access_key_id     = var.aws_access_key
        secret_access_key = var.aws_secret_key
      }
    }
    gcs_data_sink {
      bucket_name = google_storage_bucket.gcs-mirror.name
    }
  }

  schedule {
    schedule_start_date {
      year  = 2018
      month = 10
      day   = 1
    }
    schedule_end_date {
      year  = 2019
      month = 1
      day   = 15
    }
    start_time_of_day {
      hours   = 23
      minutes = 30
      seconds = 0
      nanos   = 0
    }
  }

  depends_on = [google_storage_bucket_iam_member.gcs-mirror]
}



resource "google_cloudfunctions_function" "function" {
  name        = "${var.s3_bucket_name}_mover_${terraform.workspace}"
  description = "Sftp bucket file mover for bucket ${var.s3_bucket_name}"
  runtime     = "python38"

  available_memory_mb   = 128
  source_archive_bucket = var.gcs_infra_bucket
  source_archive_object = var.sftp_mover_library
  entry_point           = "sftp_mover"

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource = google_storage_bucket.gcs-mirror.name
  }
}