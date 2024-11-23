
variable "key_name" {
  type = string
}
variable "key_path" {
  type = string
}

# variable "security_groups" {
#   type = list(string)
# }

variable "instance_type" {
  type = string
}
variable "amis" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "private_key" {
  type = string
}
variable "user" {
  type = string
}
# variable "iam_instance_profile" {
#   type = string
# }

variable "tags" {
  type = map(string)
}


variable "security_group_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}


variable "profile" {
  type = string
  description = "local aws-cli profile name"
}

variable "region" {
  type = string
  description = "aws region"
}

