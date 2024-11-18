
output "subnets_out" {
  value = [data.aws_subnets.selected.ids]
}

# output "load_balancer_info" {
#   value = module.load_balancer
# }

# output "target_group_id" {
#   value = module.target-group.id
# }
# output "target_group_arn" {
#   value = module.target-group.arn
# }

# output "listener_and_routing" {
#   value = module.listener_and_routing
# }

output "instance_id" {
  value = data.aws_instance.this.id
}