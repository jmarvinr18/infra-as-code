
terraform {
  backend "s3" {
    bucket         = "mf-higher-env-terraform-s3-state"
    key            = "tf-projects/mtf-higher-stg"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-lock-dynamo"
    encrypt        = true
  }
}
