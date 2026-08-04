# BucketOwnerEnforced disables ACLs entirely. Uploads that carry an ACL
# (for example Laravel's default "public-read" visibility) are rejected with
# AccessControlListNotSupported, so the application must not send one.
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = var.bucket_id

  rule {
    object_ownership = var.object_ownership
  }
}
