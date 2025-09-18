

variable "file_system_id" {
  description = "The ID of the EFS file system for which to create the mount target."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to add the mount target in."
  type        = string
  
}

variable "security_groups" {
  description = "A list of up to five VPC security group IDs to associate with the mount target."
  type        = list(string)
  default     = []
}