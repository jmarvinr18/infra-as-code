# Key pair variables
key_name = "tour-east-key.pub"
key_path = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/projects/toureast/gameplay/production/.ssh"

# EC2 instance Variables
amis          = "ami-0c1907b6d738188e5"
subnet_id     = "subnet-0abc6b09925b5b3d9"
private_key   = "tour-east-key"
user          = "ubuntu"
instance_type = "t3.medium"
tags = {
  "Name"        = "TOUREAST-GAMEPLAY"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

# Security Group Variables
security_group_name = "toureast-gameplay-production-sg"
vpc_id              = "vpc-009800fd2678db646"
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


profile = "metafarm"
region  = "ap-southeast-1"


cloudflare_api_token = "O6FQZbFpT1lQ0TTkQDXYXa4YCYelT0L2iZt9fPsM"
zone_id              = "9e15a2356dd49779a8d18408e6f4bd1d"
name                 = "toureast-gameplay.xctuality.com"
type                 = "A"
ttl                  = 1
proxied              = true