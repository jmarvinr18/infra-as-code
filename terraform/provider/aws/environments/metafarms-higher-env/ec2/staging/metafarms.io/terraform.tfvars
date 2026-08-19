# Key pair variables
key_name = "mtf-higher-stg-key.pub"
key_path = "/Users/rouvinramoda/Documents/xctuality/devops/infra-as-code/keys"

# EC2 instance Variables
amis          = "ami-0cab2a4234eb4eafb"
subnet_id     = "subnet-034843744ca26523c"
private_key   = "mtf-higher-stg-key"
user          = "ubuntu"
instance_type = "t3.medium"

tags = {
  "Name"        = "mtf-higher-stg"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

# Security Group Variables
security_group_name = "mtf-higher-stg-sg"
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
    from_port   = 22
    to_port     = 22
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
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
  {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
  {
    from_port   = 3202
    to_port     = 3202
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
  {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
]


profile = "metafarms-higher-env"
region  = "ap-southeast-1"


cloudflare_api_token = "85b18798f7a8f10bdf63dba670f81a518314e"
zone_id              = "9e15a2356dd49779a8d18408e6f4bd1d"
name                 = "smart"
type                 = "A"
ttl                  = 1
proxied              = true
