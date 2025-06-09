variable "url" {
  type = string
}

variable "client_id_list" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "thumbprint_list" {
  type = list(string)

  default = [null]
}