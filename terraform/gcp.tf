provider "google" {
  credentials = file("terraform-sa-key.json")
  project     = var.gcp_project_id
  region      = "us-central1"
}

resource "google_compute_address" "ip_address" {
  name = "terraform-test-${terraform.workspace}"
}

data "google_compute_network" "default" {
    name = "default"
}

resource "google_compute_firewall" "allow_http_traffic" {
    name="allow-http-${terraform.workspace}"
    network = data.google_compute_network.default.name

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]

    target_tags = ["allow-http-${terraform.workspace}"]
}

data "google_compute_image" "cos_image" {
    family = "cos-89-lts"
    project = "cos-cloud"
}

resource "google_compute_instance" "terraform_instance" {
  name         = "${var.app_name}-${terraform.workspace}-vm"
  machine_type = var.gcp_machine_type
  zone         = "us-central1-a"

  tags = google_compute_firewall.allow_http_traffic.target_tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.cos_image.self_link
    }
  }

  network_interface {
    network = data.google_compute_network.default.name

    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }
  
  service_account {
    scopes = ["storage-ro"]
  }
}