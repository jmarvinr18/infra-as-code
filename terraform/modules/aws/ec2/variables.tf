
variable "key_pair" {
  type = string
}
variable "region" {
  default = "ap-southeast-1"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "zone" {
  type = string
  default = "ap-southeast-1a"
}

variable "amis" {
  type = string
}


variable "subnet_id" {
  type = string
}

variable "key_path" {
  default = "~/Documents/personal/devops/infra-as-code/terraform/.ssh"
}

variable "tags" {
  type = map(string)
}

variable "user" {
  type = string
  default = "ubuntu"
}

variable "private_key" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
  default = []
}

variable "security_groups" {
  type = list(string)
  default = []  
}

variable "iam_instance_profile" {
  type = string
  default = ""
}