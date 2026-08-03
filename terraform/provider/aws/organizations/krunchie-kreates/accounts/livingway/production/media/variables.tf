variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "client" {
  type = string
}

variable "client_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "bucket_name" {
  description = "Globally unique bucket name"
  type        = string
}

variable "block_public_acls" {
  type = bool
}

variable "block_public_policy" {
  type = bool
}

variable "ignore_public_acls" {
  type = bool
}

variable "restrict_public_buckets" {
  type = bool
}

variable "object_ownership" {
  type    = string
  default = "BucketOwnerEnforced"
}

variable "cors_rules" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
}

variable "lifecycle_rules" {
  type = list(object({
    id                              = string
    status                          = string
    prefix                          = optional(string, "")
    noncurrent_days                 = optional(number)
    abort_incomplete_multipart_days = optional(number)
  }))
}

variable "allowed_origins" {
  description = "Sites permitted to read these objects from browser JavaScript"
  type        = list(string)
}

variable "aliases" {
  description = "Custom CDN domains. Requires acm_certificate_arn in us-east-1."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "price_class" {
  type    = string
  default = "PriceClass_200"
}

variable "cache_default_ttl" {
  type    = number
  default = 86400
}

variable "cache_max_ttl" {
  type    = number
  default = 31536000
}

variable "cache_min_ttl" {
  type    = number
  default = 0
}

variable "enable_hotlink_protection" {
  description = "Blocks embeds from outside allowed_referer_domains. Breaks social link previews and QR codes in email — see README."
  type        = bool
  default     = false
}

variable "allowed_referer_domains" {
  type    = list(string)
  default = []
}

variable "create_app_iam_user" {
  description = "Create a long-lived key for the API. Set false where the workload can assume a role and attach app_policy_arn to that instead."
  type        = bool
  default     = false
}

variable "app_iam_user_name" {
  type    = string
  default = "api-backend"
}

variable "tags" {
  type = map(string)
}
