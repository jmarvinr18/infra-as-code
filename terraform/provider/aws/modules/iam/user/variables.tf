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

variable "aws_iam_policy_document" {
  type = list(object({
      name = string
      file = string
  }))

  default = [{
      name = ""
      file = ""    
  }]
}

variable "policy_details" {
  type = list(object({
      name = string
      file = string
  }))
}