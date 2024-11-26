#### ROLE CREATION VARIABLES ####

variable "inline_policies_files" {
  type = list(object({
    name = string
    file = string
  }))
}

variable "ecs_service_role_policy_name" {
  type = string
}
variable "ecs_service_policy_path" {
  type = string
}

variable "assume_role_policy" {
  type = string
}

variable "tags" {
  type = map(string)
}


variable "profile" {
  type        = string
  description = "local aws-cli profile name"
}

variable "region" {
  type        = string
  description = "aws region"
}