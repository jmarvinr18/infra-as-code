terraform {
  backend "s3" {
    bucket         = "xct-terraform"
    key            = "dingdong/ecs/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = "true"
    dynamodb_table = "terraform-state-lock"
    # profile        = "ct-ph-whitelabel-higher"
  }
}
