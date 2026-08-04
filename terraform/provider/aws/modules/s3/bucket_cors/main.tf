# CORS governs cross-origin reads made by browser JavaScript. It does not stop
# a plain <img> embed or a direct fetch — those need no CORS permission.
resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = var.bucket_id

  dynamic "cors_rule" {
    for_each = var.cors_rules

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}
