terraform {
    backend "s3" {
        bucket         = "krunchie-tfstate"
        key            = "aws-org/terraform.tfstate"
        region         = "ap-southeast-1"
        dynamodb_table = "terraform-locks"   # or drop this and use S3 native locking (below)
        encrypt        = true
        shared_credentials_file = "~/.aws/credentials"        
    }
}

