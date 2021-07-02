terraform {
    backend "gcs" {
        bucket = "terraform-test-316516-terraform-bucket"
        prefix = "/state/terraform-test"
    }
}

provider "google" {
  credentials = file("terraform-sa-key.json")
  project     = var.gcp_project_id
  region      = "us-central1"
}

provider "aws" {}