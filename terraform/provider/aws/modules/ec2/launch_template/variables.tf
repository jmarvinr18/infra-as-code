
variable "name_prefix" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "image_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_profile" {
  type = object({
    name = string
  })
}

variable "network_interfaces" {
  type = object({
    device_index = number
    associate_public_ip_address = bool
    subnet_id = string
    security_groups = list(string)
  })

  default = {
    device_index = 0
    associate_public_ip_address = true
    subnet_id = ""
    security_groups = [""]
  }
}
variable "block_device_mappings" {
  type = object({
    device_name = string
    ebs = object({
      volume_size = number
      volume_type = string
    })
  })
}


variable "tags" {
    type = object({
      Name = string
    })
}