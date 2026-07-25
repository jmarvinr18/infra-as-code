locals {
  name = "kk-${var.client}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Deterministic subnet carving from the /16
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]          # /24s
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 1)]      # /20s
  data_subnets    = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 6, i + 16)]     # /22s
}

data "aws_availability_zones" "available" { state = "available" }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.data_subnets

  # NAT: one per AZ in prod, single in dev
  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat
  one_nat_gateway_per_az = !var.single_nat

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Flow logs -> CloudWatch, mandatory
  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags   = { Tier = "public" }
  private_subnet_tags  = { Tier = "app" }
  database_subnet_tags = { Tier = "data" }

  tags = { Name = "${local.name}-vpc" }
}