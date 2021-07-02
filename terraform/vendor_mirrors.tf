module "aws-gcp-mirror" {
    source = "../aws-gcp-mirror"
    for_each={for v in var.s3_vendor_list: v.s3_bucket_name => v}
    s3_bucket_name=each.value.s3_bucket_name
    gcs_bucket_name=each.value.gcs_bucket_name
    aws_access_key=var.aws_access_key
    aws_secret_key=var.aws_secret_key
    project=var.gcp_project_id
}