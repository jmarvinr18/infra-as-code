
variable "key_name" {
  type = string
}
variable "key_path" {
  type = string
}
variable "key_pair" {
  type = string
}
variable "vpc_security_group_ids" {
  type = list(string)
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
variable "iam_instance_profile" {
  type = string
}

variable "tags" {
  type = map(string)
}