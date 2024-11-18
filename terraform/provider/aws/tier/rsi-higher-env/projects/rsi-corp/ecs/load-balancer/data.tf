data "aws_security_group" "this" {
  name = "rsi-corp-prod-sg"
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Provisioner"
    values = ["terraform"]
  }
  filter {
    name   = "tag:Name"
    values = ["higher-rsi-infra"]
  }  
  filter {
    name   = "tag:Tier"
    values = ["high"]
  }   
  filter {
    name   = "tag:Env"
    values = ["higher"]
  }     
}

data "aws_subnets" "selected" {
  filter {
    name   = "tag:Name"
    values = ["public-ap-southeast-1*"]
  }
}