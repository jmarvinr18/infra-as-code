resource "aws_cloudfront_cache_policy" "this" {
  name        = var.name
  comment     = var.comment
  default_ttl = var.default_ttl
  max_ttl     = var.max_ttl
  min_ttl     = var.min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = var.enable_brotli
    enable_accept_encoding_gzip   = var.enable_gzip

    cookies_config {
      cookie_behavior = var.cookie_behavior
    }

    headers_config {
      header_behavior = length(var.headers) > 0 ? "whitelist" : "none"

      dynamic "headers" {
        for_each = length(var.headers) > 0 ? [var.headers] : []

        content {
          items = headers.value
        }
      }
    }

    query_strings_config {
      query_string_behavior = var.query_string_behavior
    }
  }
}
