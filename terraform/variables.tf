variable "app_name" {
    type = string
}

variable "gcp_project_id" {
    type = string
}

variable "gcs_bucket" {
    type = string
}

variable "aws_access_key" {
    type = string
}

variable "aws_secret_key" {
    type = string
}

variable "s3_vendor_list" {
  type = list(object({
    s3_bucket_name = string
    gcs_bucket_name = string
    vendor_path = string
    vendor_name = string
  }))
}

#variable "gcs_vendor_list" {
#  type = list(object({
#    gcs_bucket_name = string
#    vendor_path = string
#    vendor_name = string
#  }))
#}