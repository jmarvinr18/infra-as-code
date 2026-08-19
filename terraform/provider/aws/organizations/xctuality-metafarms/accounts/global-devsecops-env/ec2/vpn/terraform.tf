terraform {
  backend "s3" {
    bucket                  = "mf-devops-terraform-s3-state"
    dynamodb_table          = "terraform-state-lock-dynamo"
    key                     = "tf-projects/wgvpn"
    region                  = "ap-southeast-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}