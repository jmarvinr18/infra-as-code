output "vpc_id"            { value = module.vpc.vpc_id }
output "private_subnets"   { value = module.vpc.private_subnets }
output "data_subnets"      { value = module.vpc.database_subnets }
output "endpoints_sg_id"   { value = aws_security_group.endpoints.id }
output "vpc_cidr"          { value = var.vpc_cidr }