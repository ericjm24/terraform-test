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

variable "s3_mirror_list" {
  type = list(string)
}

variable "gcp_function_list" {
  type = list(string)
}