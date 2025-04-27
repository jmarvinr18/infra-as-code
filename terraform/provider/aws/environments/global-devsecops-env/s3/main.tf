resource "aws_s3_bucket" "test-bucket-3123" {
  bucket = "test-bucket-3123"

  tags = {
    Name = "myBucketTagName123"
  }
}