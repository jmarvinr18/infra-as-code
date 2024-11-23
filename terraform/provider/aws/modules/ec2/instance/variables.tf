
variable "key_pair" {
  type = string
}
variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "instance_type" {
  type    = string
}

variable "zone" {
  type    = string
  default = "ap-southeast-1a"
}

variable "amis" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}


variable "tags" {
  type = map(string)
}

variable "user" {
  type    = string
  default = "ubuntu"
}

variable "private_key" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}

variable "associate_public_ip_address" {
  type = bool
  default = true
}