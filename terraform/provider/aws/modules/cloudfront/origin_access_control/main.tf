# Lets a distribution read a private bucket without the bucket ever being
# public. Replaces the older Origin Access Identity.
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.name
  description                       = var.description
  origin_access_control_origin_type = var.origin_type
  signing_behavior                  = var.signing_behavior
  signing_protocol                  = var.signing_protocol
}
