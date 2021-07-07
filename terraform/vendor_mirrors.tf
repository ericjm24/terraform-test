data "google_storage_bucket_object" "archive" {
  name   = "${terraform.workspace}/sftp_mover.zip"
  bucket = var.gcs_bucket
}

module "aws-gcp-mirror" {
    source = "../aws-gcp-mirror"
    for_each= (terraform.workspace == "prod" ? toset(var.s3_mirror_list) : toset([]))
    s3_bucket_name=each.value
    gcs_bucket_name="s3mirror_${each.value}"
    gcs_infra_bucket=var.gcs_bucket
    sftp_mover_library=data.google_storage_bucket_object.archive.name
    aws_access_key=var.aws_access_key
    aws_secret_key=var.aws_secret_key
    project=var.gcp_project_id
}

# resource "google_cloudfunctions_function" "function" {
#   for_each = toset(var.gcp_function_list)
#   name        = "${each.value}_${terraform.workspace}"
#   description = "My function"
#   runtime     = "python38"

#   available_memory_mb   = 128
#   source_archive_bucket = var.gcs_bucket
#   source_archive_object = data.google_storage_bucket_object.archive.name
#   trigger_http          = true
#   entry_point           = each.value
# }