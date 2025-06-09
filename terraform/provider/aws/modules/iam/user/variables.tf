variable "iam_user_name" {
  type = string
}

variable "path" {
  type = string
  default = "/"
}


variable "tags" {
  type = map(string)
  default = {
    "name" = ""
  }
}