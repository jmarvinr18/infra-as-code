variable "name" {
  type = string
}

variable "comment" {
  type    = string
  default = ""
}

variable "default_ttl" {
  type    = number
  default = 86400
}

variable "max_ttl" {
  type    = number
  default = 31536000
}

variable "min_ttl" {
  type    = number
  default = 0
}

variable "cookie_behavior" {
  type    = string
  default = "none"
}

variable "query_string_behavior" {
  description = "Used when query_strings is empty; otherwise the behavior is whitelist"
  type        = string
  default     = "none"
}

# Media keys are derived from the record id, so a replaced image reuses its key
# and its URL. The application appends a content hash to distinguish versions,
# which only busts the cache if that parameter is part of the cache key.
variable "query_strings" {
  type    = list(string)
  default = []
}

# Origin and the CORS preflight headers must be in the cache key, or one
# origin's CORS response gets served to another.
variable "headers" {
  type    = list(string)
  default = []
}

variable "enable_brotli" {
  type    = bool
  default = true
}

variable "enable_gzip" {
  type    = bool
  default = true
}
