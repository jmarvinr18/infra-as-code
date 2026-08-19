terraform {
  required_version = ">= 1.6"
  backend "s3" {
    bucket         = "krunchie-tfstate"
    key            = "clients/donato-and-zarate/production/budget.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}