variable "name" {
  type = string
}

variable "comment" {
  type    = string
  default = ""
}

variable "allowed_origins" {
  description = "Origins permitted to read these objects from browser JavaScript"
  type        = list(string)
  default     = []
}

variable "allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "allowed_headers" {
  type    = list(string)
  default = ["*"]
}

variable "allow_credentials" {
  type    = bool
  default = false
}

variable "max_age_seconds" {
  type    = number
  default = 3600
}

variable "hsts_max_age_seconds" {
  type    = number
  default = 31536000
}

variable "referrer_policy" {
  type    = string
  default = "strict-origin-when-cross-origin"
}
