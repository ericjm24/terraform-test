module "aws-gcp-mirror" {
    source = "../aws-gcp-mirror"
    for_each= (terraform.workspace == "prod" ? toset(var.s3_mirror_list) : toset([]))
    s3_bucket_name=each.value
    gcs_bucket_name="s3mirror_${each.value}"
    gcs_infra_bucket=var.gcs_bucket
    aws_access_key=var.aws_access_key
    aws_secret_key=var.aws_secret_key
    project=var.gcp_project_id
}