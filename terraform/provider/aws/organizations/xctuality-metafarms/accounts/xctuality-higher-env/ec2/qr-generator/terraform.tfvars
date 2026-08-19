# Key pair variables
key_name = "qr-generator-ssh-key.pub"
key_path = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/keys"

# EC2 instance Variables
amis          = "ami-0c1907b6d738188e5"
subnet_id     = "subnet-0edb5e532c0528c56"
private_key   = "qr-generator-ssh-key"
user          = "ubuntu"
instance_type = "t3.medium"
tags = {
  "Name"        = "xct-prd-qr-generator"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

# Security Group Variables
security_group_name = "xct-prd-qr-generator"
vpc_id              = "vpc-0660fffb627c22960"
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


profile = "xctuality-higher-env"
region  = "ap-southeast-1"


cloudflare_api_token = "O6FQZbFpT1lQ0TTkQDXYXa4YCYelT0L2iZt9fPsM"
zone_id              = "d12602de13da222a3e5be789771db4ff"
name                 = "toureast.xctualyfe.com"
type                 = "A"
ttl                  = 1
proxied              = true