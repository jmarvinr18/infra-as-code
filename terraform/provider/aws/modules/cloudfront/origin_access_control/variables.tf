variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "origin_type" {
  type    = string
  default = "s3"
}

variable "signing_behavior" {
  type    = string
  default = "always"
}

variable "signing_protocol" {
  type    = string
  default = "sigv4"
}
