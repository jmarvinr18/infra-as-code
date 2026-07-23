variable "domain" {
  type = string
}

variable "region" {
  type = string
}

variable "repository" {
  type = string
}


variable "external_connection_name" {
  type = string
}


variable "tags" {
  type = map(string)
}

variable "upstream_repos" {
  description = "Upstream proxy repos: key = repo name, value = external connection name"
  type        = map(string)
}