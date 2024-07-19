
variable "identifier" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "allocated_storage" {
  type    = number
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

variable "skip_final_snapshot" {
  type = bool
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "parameter_name" {
  type = string
}

variable "family" {
  type = string
}
variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
}