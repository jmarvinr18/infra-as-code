terraform {
  backend "s3" {
    bucket                  = "xctuality-higher-terraform-s3-state"
    dynamodb_table          = "terraform-state-lock-dynamo"
    key                     = "tf-projects/xctuality/eks/rbac"
    region                  = "ap-southeast-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}