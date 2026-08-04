resource "aws_cloudfront_response_headers_policy" "this" {
  name    = var.name
  comment = var.comment

  dynamic "cors_config" {
    for_each = length(var.allowed_origins) > 0 ? [1] : []

    content {
      access_control_allow_credentials = var.allow_credentials
      origin_override                  = true

      access_control_allow_headers {
        items = var.allowed_headers
      }

      access_control_allow_methods {
        items = var.allowed_methods
      }

      access_control_allow_origins {
        items = var.allowed_origins
      }

      access_control_max_age_sec = var.max_age_seconds
    }
  }

  security_headers_config {
    content_type_options {
      override = true
    }

    strict_transport_security {
      access_control_max_age_sec = var.hsts_max_age_seconds
      include_subdomains         = true
      override                   = true
    }

    referrer_policy {
      referrer_policy = var.referrer_policy
      override        = true
    }
  }
}
