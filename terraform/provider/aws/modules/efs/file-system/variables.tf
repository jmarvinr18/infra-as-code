

variable "creation_token" {
  type = string
}

variable "performance_mode" {
  type    = string
  default = "generalPurpose"
  
}
variable "throughput_mode" {
  type    = string
  default = "bursting"
}

variable "encrypted" {
  type    = bool
  default = true
  
}

variable "tags" {
  type = map(string)
}