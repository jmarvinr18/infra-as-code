# Key pair variables
key_name = "crowdfunding-mtf-key.pub"
key_path = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/keys"

# EC2 instance Variables
amis          = "ami-05c91092562b09c80"
subnet_id     = "subnet-01732ccd1fa6a8143"
private_key   = "crowdfunding-mtf-key"
user          = "ubuntu"
instance_type = "t3.medium"
tags = {
  "Name"        = "crowdfunding-mtf-stg"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

# Security Group Variables
security_group_name = "crowdfunding-mtf-sg-stg"
vpc_id              = "vpc-02ec290473a6e04ad"
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


profile = "metafarms-higher-env"
region  = "ap-southeast-1"


cloudflare_api_token = "O6FQZbFpT1lQ0TTkQDXYXa4YCYelT0L2iZt9fPsM"
zone_id              = "d12602de13da222a3e5be789771db4ff"
name                 = "crowdfunding.metafarms.io"
type                 = "A"
ttl                  = 1
proxied              = true