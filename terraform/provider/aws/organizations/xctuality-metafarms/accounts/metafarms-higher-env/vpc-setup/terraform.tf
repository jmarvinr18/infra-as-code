terraform {
  backend "s3" {
    bucket                  = "mf-higher-env-terraform-s3-state"
    dynamodb_table          = "terraform-state-lock-dynamo"
    key                     = "tf-projects/vpc"
    region                  = "ap-southeast-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}