variable "role_name" {
  type = string
}

variable "role" {
  type = string
  default = ""
}

variable "policy_arn" {
  type = string
  default = ""
}


variable "inline_policy" {
  type = list(object({
      name = string
      file = string
  }))

  default = [{
      name = ""
      file = ""    
  }]
}

variable "assume_role_policy" {
  type = string
}

variable "tags" {
  type = map(string)
}

