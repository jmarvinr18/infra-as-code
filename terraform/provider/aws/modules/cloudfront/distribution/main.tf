resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  comment             = var.comment
  price_class         = var.price_class
  is_ipv6_enabled     = var.is_ipv6_enabled
  default_root_object = var.default_root_object
  aliases             = var.aliases
  tags                = var.tags

  origin {
    domain_name              = var.origin_domain_name
    origin_id                = var.origin_id
    origin_access_control_id = var.origin_access_control_id
  }

  default_cache_behavior {
    target_origin_id       = var.origin_id
    viewer_protocol_policy = var.viewer_protocol_policy
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    compress               = var.compress

    cache_policy_id            = var.cache_policy_id
    response_headers_policy_id = var.response_headers_policy_id

    dynamic "function_association" {
      for_each = { for f in var.function_associations : f.event_type => f }

      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  # CloudFront only accepts ACM certificates issued in us-east-1, whatever
  # region the origin lives in.
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == ""
    acm_certificate_arn            = var.acm_certificate_arn == "" ? null : var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn == "" ? null : "sni-only"
    minimum_protocol_version       = var.acm_certificate_arn == "" ? "TLSv1" : var.minimum_protocol_version
  }

  lifecycle {
    precondition {
      condition     = length(var.aliases) == 0 || var.acm_certificate_arn != ""
      error_message = "acm_certificate_arn is required when aliases are set, and the certificate must be issued in us-east-1."
    }
  }
}
