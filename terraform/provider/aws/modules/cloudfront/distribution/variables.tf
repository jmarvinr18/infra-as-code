variable "comment" {
  type    = string
  default = ""
}

variable "enabled" {
  type    = bool
  default = true
}

variable "price_class" {
  type    = string
  default = "PriceClass_200"
}

variable "is_ipv6_enabled" {
  type    = bool
  default = true
}

variable "default_root_object" {
  type    = string
  default = null
}

variable "aliases" {
  description = "Custom domains served by this distribution"
  type        = list(string)
  default     = []
}

variable "origin_domain_name" {
  description = "For S3 use bucket_regional_domain_name"
  type        = string
}

variable "origin_id" {
  type = string
}

variable "origin_access_control_id" {
  type    = string
  default = null
}

variable "viewer_protocol_policy" {
  type    = string
  default = "redirect-to-https"
}

variable "allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "compress" {
  type    = bool
  default = true
}

variable "cache_policy_id" {
  type = string
}

variable "response_headers_policy_id" {
  type    = string
  default = null
}

variable "function_associations" {
  type = list(object({
    event_type   = string
    function_arn = string
  }))
  default = []
}

variable "acm_certificate_arn" {
  description = "Must be issued in us-east-1. Leave empty to use the default CloudFront certificate."
  type        = string
  default     = ""
}

variable "minimum_protocol_version" {
  type    = string
  default = "TLSv1.2_2021"
}

variable "geo_restriction_type" {
  type    = string
  default = "none"
}

variable "geo_restriction_locations" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
