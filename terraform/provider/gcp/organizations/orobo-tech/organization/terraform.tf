terraform {
  required_version = ">= 1.6"
  backend "gcs" {
    bucket = "orobo-tech-tfstate"
    prefix = "orobo-tech/organization"
  }
}
