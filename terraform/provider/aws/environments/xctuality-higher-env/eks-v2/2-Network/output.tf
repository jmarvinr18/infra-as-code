output "public_zone1_id" {
  value = module.eks_subnets.ids
}

output "route_table_id" {
  value = module.route_table.ids
}

# output "eks_subnets_debug" {
#   value = module.eks_subnets
# }