locals {
  env    = "staging"
  region = "ap-southeast-1"
  zone1  = "ap-southeast-1a"
  zone2  = "ap-southeast-1b"
}

locals {
  public_zone_1 = [
    for s in module.eks_subnets.details :
    s if try(s.tags["Name"], "") == "staging-public-ap-southeast-1a"
  ]

  public_zone_2 = [
    for s in module.eks_subnets.details :
    s if try(s.tags["Name"], "") == "staging-public-ap-southeast-1b"
  ]  

  private_zone_1 = [
    for s in module.eks_subnets.details :
    s if try(s.tags["Name"], "") == "staging-private-ap-southeast-1a"
  ]    

  private_zone_2 = [
    for s in module.eks_subnets.details :
    s if try(s.tags["Name"], "") == "staging-private-ap-southeast-1b"
  ]      

  route_table_public = [
    for s in module.route_table.details :
    s if try(s.tags["Zone"], "") == "public"
  ]        
  route_table_private = [
    for s in module.route_table.details :
    s if try(s.tags["Zone"], "") == "private"
  ]     
}
