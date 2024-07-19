
variable "identifier" {
  type = string
}

variable "allocated_storage" {
  type = number
  default = 10
}

# sample value: "mydb"
variable "db_name" {
  type = string
}
# sample value: "mysql"
variable "engine" {
  type = string
}
# sample value: "8.0"
variable "engine_version" {
  type = string
}
#sample value: "db.t3.micro"
variable "instance_class" {
  type = string
}
variable "username" {
  type = string
}
variable "password" {
  type = string
}
#sample value: "default.mysql8.0"
variable "parameter_group_name" {
  type = string
}
variable "db_subnet_group_name" {
  type = string
}

variable "skip_final_snapshot" {
  type = bool
  default = false
}

variable "deletion_protection" {
  type = bool
  default = true
}
variable "vpc_security_group_ids" {
  type = list(string)
}