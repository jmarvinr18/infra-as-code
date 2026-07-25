variable "client"{ 
    type = string 
}

variable "client_account_id" {
    type = string 
}

variable "environment"{ 
    type = string 
}

variable "region" { 
    type = string
    default = "ap-southeast-1"
}

variable "vpc_cidr"{ 
    type = string 
}

variable "az_count" { 
    type = number  
    default = 3 
}

variable "single_nat"{ 
    type = bool    
    default = false 
}

# Interface endpoints to create for the RAG stack
variable "interface_endpoints" {
  type    = list(string)
  default = [
    "bedrock-runtime", "bedrock", "aoss",
    "secretsmanager", "logs", "sts",
    "ecr.api", "ecr.dkr",
  ]
}