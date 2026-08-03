resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = var.bucket_id

  dynamic "rule" {
    for_each = var.rules

    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix
      }

      # Re-uploading under the same key supersedes the previous object;
      # versioning keeps it, so it is expired rather than kept forever.
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_days == null ? [] : [rule.value.noncurrent_days]

        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_days == null ? [] : [rule.value.abort_incomplete_multipart_days]

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }
    }
  }
}
