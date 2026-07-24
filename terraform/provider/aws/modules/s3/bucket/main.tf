resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags = var.tags

    # Guardrail: don't let a stray `terraform destroy` delete your state history.
  lifecycle {
    prevent_destroy = true
  }
}

# Keep every version of the state file so you can recover from corruption.
resource "aws_s3_bucket_versioning" "this" {

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt objects at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

# Block all public access — state can contain secrets.
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}