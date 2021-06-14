terraform {
    backend "gcs" {
        bucket = "terraform-test-316516-terraform-bucket"
        prefix = "/state/terraform-test"
    }
}