# Key pair variables
key_name = "metafarms-crowdfunding-ssh-key.pub"
key_path = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/keys"

# EC2 instance Variables
amis          = "ami-05c91092562b09c80"
subnet_id     = "subnet-034843744ca26523c"
private_key   = "metafarms-crowdfunding-ssh-key"
user          = "ubuntu"
instance_type = "t3.medium"

tags = {
  "Name"        = "metafarms-crowdfunding-instance"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

# Security Group Variables
security_group_name = "mf-crowdfunding-sg"
vpc_id              = "vpc-05d7a9a408b88bcd3"
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
    from_port   = 8080
    to_port     = 8080
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
  {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },  
]


profile = "metafarms-higher-env"
region  = "ap-southeast-1"


# cloudflare_api_token = ""
# zone_id              = ""
# name                 = "jenkins.xctuality.com"
# type                 = "A"
# ttl                  = 1
# proxied              = true