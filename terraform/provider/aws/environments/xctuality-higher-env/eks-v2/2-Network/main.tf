##### VPC SETUP

module "eks_vpc" {
  source = "../../../../modules/vpc"
  cidr_block = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support
  tags = var.tags
}


module "eks_igw" {
  source = "../../../../modules/internet_gateway"
  vpc_id = module.eks_vpc.id
  tags = var.tags
}

module "eks_eip" {
  source = "../../../../modules/eip"

  domain = ""
  tags = var.tags
}


module "eks_subnets" {
  source = "../"
}


module "eks_nat" {
  source = "../../../../modules/nat_gateway"
  subnet_id = ""
  allocation_id = module.eks_eip.id
  tags = var.tags
}