variable "security_group_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
    description = "List of ingress rules for the security group"
    type = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
        description = string
    }))
    default = [{
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = ""
    },
    {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = ""
    }]     
}

variable "egress_rules" {
    description = "List of egress rules for the security group"
    type = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
        description = string
    }))
    default = [{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = ""
    }]    
}

variable "tags" {
  type = map(string)
  default = {
    "name" = ""
  }
}