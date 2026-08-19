terraform {
  required_providers {
    google = { source = "hashicorp/google", version = ">= 6.0" }
  }
}

provider "google" {
  project = var.monitoring_project
  region  = var.region

  default_labels = {
    app         = var.app
    environment = var.environment
    provisioner = "terraform"
  }
}
