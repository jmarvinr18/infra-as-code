data "aws_security_group" "this" {
  name = "dos2u_sg_prod"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Provisioner"
    values = ["terraform"]
  }
  filter {
    name   = "tag:Name"
    values = ["lower-rsi-infra"]
  }  
  filter {
    name   = "tag:Tier"
    values = ["dta"]
  }   
  filter {
    name   = "tag:Env"
    values = ["lower"]
  }     
}

data "aws_subnets" "selected" {
  filter {
    name   = "tag:Name"
    values = ["public-ap-southeast-1*"]
  }
}