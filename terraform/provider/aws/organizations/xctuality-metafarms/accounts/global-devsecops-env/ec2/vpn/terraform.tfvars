# Key pair variables
key_name = "wgvpn-global-devops-key.pub"
key_path = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/keys"

# EC2 instance Variables
amis          = "ami-0c1907b6d738188e5"
subnet_id     = "subnet-0557410b9312bb8aa"
private_key   = "wgvpn-global-devops-key"
user          = "ubuntu"
instance_type = "t3.small"

tags = {
  "Name"        = "global-devsecops-wgvpn"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

# Security Group Variables
security_group_name = "wgvpn-sg"
vpc_id              = "vpc-0c2b4b9b6f650cd4b"
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
]


profile = "global-devsecops-env"
region  = "ap-southeast-1"


