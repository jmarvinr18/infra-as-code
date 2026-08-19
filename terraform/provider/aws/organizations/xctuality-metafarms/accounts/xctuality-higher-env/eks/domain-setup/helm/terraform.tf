terraform {
  backend "s3" {
    bucket                  = "xctuality-higher-terraform-s3-state"
    dynamodb_table          = "terraform-state-lock-dynamo"
    key                     = "tf-projects/xctuality.com/helm-nginx"
    region                  = "ap-southeast-1"
    shared_credentials_file = "~/.aws/credentials"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }
  }
}