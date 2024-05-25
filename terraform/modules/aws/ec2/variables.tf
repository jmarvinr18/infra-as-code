variable "REGION" {
  default = "ap-southeast-1"
}

variable "INSTANCE_TYPE" {
  default = "t3.medium"
}

variable "ZONE1" {
  default = "ap-southeast-1a"
}

variable "AMIS" {
  type = string
  default = "ami-0be48b687295f8bd6"
}
variable "USER" {
  default = "ubuntu"
}

variable "VPC_ID" {
  default = "vpc-082947f177e90b38c"
}

variable "SUBNET_ID" {
  default = "subnet-00bb21ffc18c51291"
}

variable "KEY_PATH" {
  default = "~/Documents/personal/devops/infra-as-code/terraform/.ssh"
}

variable "tags" {
  type = map(string)
  default = {
    "Name"        = "jenkins"
    "Environment" = "develop"
    "Release"     = "latest"
    "Created-by"  = "packer-jmarvinr"
  }
}