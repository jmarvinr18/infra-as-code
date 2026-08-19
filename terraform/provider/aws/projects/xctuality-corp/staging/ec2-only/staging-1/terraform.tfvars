# Key pair variables
key_name = "xcorp-tf-key.pub"
key_path = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/projects/xctuality-corp/staging/ec2-only/.ssh"

# EC2 instance Variables
amis        = "ami-060e277c0d4cce553"
subnet_id   = "subnet-0e1f9878"
private_key = "xcorp-tf-key"
user        = "ubuntu"
instance_type = "t3.micro"
tags = {
  "Name"        = "TEST-XCORP-SITE"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

# Security Group Variables
security_group_name = "xcorp-staging-sg"
vpc_id              = "vpc-4dba6b29"
ingress_rules = [{
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
  },
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
]  


profile = "xctuality"
region = "ap-southeast-1"