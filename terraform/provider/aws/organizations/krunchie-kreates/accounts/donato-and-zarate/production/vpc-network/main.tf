

module "network" {
  source = "../../../../network-infrastructure"
  client            = var.client
  environment       = var.environment
  region            = var.region
  vpc_cidr          = var.vpc_cidr   # from the CIDR registry, Section 4.3
  single_nat        = var.single_nat            # prod = HA
  
}