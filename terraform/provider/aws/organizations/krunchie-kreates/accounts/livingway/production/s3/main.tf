

module "s3_bucket" {
  source = "../../../modules/s3/bucket"
  bucket_name = var.bucket_name
  tags = var.tags
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
