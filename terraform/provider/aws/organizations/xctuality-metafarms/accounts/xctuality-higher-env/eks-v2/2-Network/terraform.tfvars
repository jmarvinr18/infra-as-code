region     = "ap-southeast-1"
cidr_block = "10.0.0.0/16"

enable_dns_hostnames = true
enable_dns_support   = true
domain               = "vpc"

subnets = [
  {
    cidr_block        = "10.0.0.0/19"
    availability_zone = "ap-southeast-1a"
    type              = "private"
    subnet_tags = {
      "Name"                                  = "staging-private-ap-southeast-1a"
      "kubernetes.io/role/internal-elb"       = "1"
      "kubernetes.io/cluster/staging-xct-eks" = "owned"
    }
  },
  {
    cidr_block        = "10.0.32.0/19"
    availability_zone = "ap-southeast-1b"
    type              = "private"
    subnet_tags = {
      "Name"                                  = "staging-private-ap-southeast-1b"
      "kubernetes.io/role/internal-elb"       = "1"
      "kubernetes.io/cluster/staging-xct-eks" = "owned"
    }
  },
  {
    cidr_block        = "10.0.64.0/19"
    availability_zone = "ap-southeast-1a"
    type              = "public"
    subnet_tags = {
      "Name"                                  = "staging-public-ap-southeast-1a"
      "kubernetes.io/role/elb"                = "1"
      "kubernetes.io/cluster/staging-xct-eks" = "owned"
    }
  },
  {
    cidr_block        = "10.0.96.0/19"
    availability_zone = "ap-southeast-1b"
    type              = "public"
    subnet_tags = {
      "Name"                                  = "staging-public-ap-southeast-1b"
      "kubernetes.io/role/elb"                = "1"
      "kubernetes.io/cluster/staging-xct-eks" = "owned"
    }
  }
]

route_tables = []

tags = {
  "Name"        = "xctuality-higher-env-eks"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}
