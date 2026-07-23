# Key pair variables
key_name = ""
key_path = ""

# EC2 instance Variables
amis          = ""
subnet_id     = ""
private_key   = ""
user          = "ubuntu"
instance_type = "t3.medium"
tags = {
  "Name"        = "TEST2-XCORP-SITE"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

# Security Group Variables
security_group_name = ""
vpc_id              = ""
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


profile = ""
region  = ""


cloudflare_api_token = ""
zone_id              = ""
name                 = "smart"
type                 = "A"
ttl                  = 1
proxied              = true