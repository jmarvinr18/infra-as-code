terraform {
  required_providers {
    google = { source = "hashicorp/google", version = ">= 6.0" }
  }
}

provider "google" {
  region = var.region

  default_labels = {
    app         = var.app
    provisioner = "terraform"
  }
}
