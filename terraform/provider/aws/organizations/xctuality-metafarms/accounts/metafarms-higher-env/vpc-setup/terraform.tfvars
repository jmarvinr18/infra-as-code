vpc_cidr_block = "10.0.0.0/16"

enable_dns_support = true

enable_dns_hostnames = true

tags = {
  "Name"        = "metafarms-higher-env-vpc"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

public = "public"
private = "private"

zones = ["ap-southeast-1a", "ap-southeast-1b"]

zone_cidr_block = {
  "private_zone_1" = "10.0.0.0/19"
  "private_zone_2" = "10.0.32.0/19"
  "public_zone1"   = "10.0.64.0/19"
  "public_zone2"   = "10.0.96.0/19"
}


map_public_ip_on_launch = true

aws_eip_domain = "vpc"

route_table_cidr_block = "0.0.0.0/0"