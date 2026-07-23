##### VPC SETUP ##############################################################

module "eks_vpc" {
  source               = "../../../../modules/vpc"
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = var.tags
}


##### INTERNET GATEWAY SETUP ##############################################################

module "eks_igw" {
  source = "../../../../modules/internet_gateway"
  vpc_id = module.eks_vpc.id
  tags   = var.tags

  depends_on = [ module.eks_vpc ]
}

##### ELASTIC IP SETUP ##############################################################

module "eks_eip" {
  source = "../../../../modules/eip"
  domain = var.domain

  tags = var.tags
}

##### SUBNETS SETUP ##############################################################

module "eks_subnets" {
  source = "../../../../modules/subnets"
  vpc_id = module.eks_vpc.id

  subnets = var.subnets


  tags = var.tags

  depends_on = [ module.eks_vpc ]
}

##### NAT GATEWAY SETUP ##############################################################

module "eks_nat" {
  source        = "../../../../modules/nat_gateway"
  subnet_id     = local.public_zone_1[0].id
  allocation_id = module.eks_eip.id
  tags          = var.tags

  depends_on = [ module.eks_subnets ]
}

##### ROUTE TABLE SETUP ##############################################################

module "route_table" {
  source = "../../../../modules/route/table"
  vpc_id = module.eks_vpc.id

  route_tables = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.eks_nat.id
      zone_tag = {
        "Zone" = "private"
      }
    },
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.eks_igw.id
      zone_tag = {
        "Zone" = "public"
      }
    }
  ]

  tags = var.tags

  depends_on = [ module.eks_vpc, module.eks_nat.id, module.eks_igw.id ]
}


##### ROUTE TABLE ASSOCIATION SETUP ##############################################################

module "route_table_association" {
  source = "../../../../modules/route/table-association"
  route_table_associations = [
    {
      subnet_id      = local.public_zone_1[0].id
      route_table_id = local.route_table_public[0].id
    },
    {
      subnet_id      = local.public_zone_2[0].id
      route_table_id = local.route_table_public[0].id
    },    
    {
      subnet_id      = local.private_zone_1[0].id
      route_table_id = local.route_table_private[0].id
    },
    {
      subnet_id      = local.private_zone_2[0].id
      route_table_id = local.route_table_private[0].id
    }    
  ]

  depends_on = [ module.eks_subnets, module.route_table ]
}