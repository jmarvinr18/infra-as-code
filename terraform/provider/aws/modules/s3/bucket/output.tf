output "name" {
    description = "The name of the S3 bucket"
    value       = aws_s3_bucket.this.bucket
}

output "bucket_id" {
  value      = aws_s3_bucket.this.id
}