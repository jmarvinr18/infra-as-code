variable "name" {
  type = string
}

variable "code" {
  description = "JavaScript source for the edge function"
  type        = string
}

variable "runtime" {
  type    = string
  default = "cloudfront-js-2.0"
}

variable "comment" {
  type    = string
  default = ""
}

variable "publish" {
  type    = bool
  default = true
}
