terraform {
  required_version = ">= 1.3"

  required_providers {
    aws     = { source = "hashicorp/aws", version = ">= 5.40" }
    archive = { source = "hashicorp/archive", version = ">= 2.4" }
    random  = { source = "hashicorp/random", version = ">= 3.5" }
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.client_account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Client      = var.client
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = "livingway-lwa-vector-api"
    }
  }
}
