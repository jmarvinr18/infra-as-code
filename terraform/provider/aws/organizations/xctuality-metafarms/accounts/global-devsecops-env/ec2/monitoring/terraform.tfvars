# Key pair variables
key_name = "monitoring-mf-global-devops-key.pub"
key_path = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/keys"

# EC2 instance Variables
amis          = "ami-0c1907b6d738188e5"
subnet_id     = "subnet-0557410b9312bb8aa"
private_key   = "monitoring-mf-global-devops-key"
user          = "ubuntu"
instance_type = "t3.medium"

tags = {
  "Name"        = "global-devsecops-monitoring"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

# Security Group Variables
security_group_name = "monitoring-sg"
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
    from_port   = 9090
    to_port     = 9090
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


cloudflare_api_token = ""
zone_id              = ""
name                 = "prometheus.xctuality.com"
type                 = "A"
ttl                  = 1
proxied              = true