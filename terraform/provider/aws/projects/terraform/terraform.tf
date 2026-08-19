terraform {
  backend "s3" {
    bucket         = "xct-terraform"
    key            = "terraform/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = "true"
    dynamodb_table = "terraform-state-lock"
    # profile        = "rsi-higher"
  }
}
