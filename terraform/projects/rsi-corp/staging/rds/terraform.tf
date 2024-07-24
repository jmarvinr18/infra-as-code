terraform {
  backend "s3" {
    bucket         = "rsi-lower-tf-state"
    key            = "terraform/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = "true"
    dynamodb_table = "terraform-state-lock"
    # profile        = "ct-ph-torrospin-higher"
  }
}
