variable "region" {
  type = string
}

variable "domain" {
  type = string
}

variable "repository" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "external_connection_name" {
  type = string
}
variable "description" {
  type = string
}

variable "upstreams" {
  description = "Ordered list of upstream repository names (search order matters)"
  type        = list(string)
}

variable "upstream_repos" {
  description = "Upstream proxy repos: key = repo name, value = external connection name"
  type        = map(string)
}
# variable "upstream_repository_name" {
#   type = string
# }

variable "repository_name" {
  type = string
}