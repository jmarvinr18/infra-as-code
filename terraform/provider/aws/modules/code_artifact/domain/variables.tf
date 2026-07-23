variable "domain" {
  type = string
}


variable "encryption_key" {
  type = string
  default = ""
}

variable "tags" {
  type = map(string)
}
