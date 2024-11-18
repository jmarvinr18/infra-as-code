resource "aws_s3_bucket" "terraform-state" {
  bucket = "rsi-lower-tf-state"

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_s3_bucket_versioning" "terraform-state-bucket-versioning" {
  bucket = aws_s3_bucket.terraform-state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}