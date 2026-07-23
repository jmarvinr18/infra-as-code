variable "domain" {
  type = string
}

variable "region" {
  type = string
}

variable "repository" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "description" {
  type = string
}

# variable "upstream_repository_name" {
#   type = string
# }

variable "tags" {
  type = map(string)
}

variable "upstreams" {
  description = "Ordered list of upstream repository names (search order matters)"
  type        = list(string)
}
