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
  type    = string
  default = "none"
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
