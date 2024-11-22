
output "subnets_out" {
  value = [data.aws_subnets.selected.ids]
}

output "load_balancer_info" {
  value = module.load_balancer
}

output "load_balancer_cname" {
  value = module.load_balancer.cname
}

output "target_group_id" {
  value = module.target_group.id
}
output "target_group_arn" {
  value = module.target_group.arn
}

output "listener_and_routing" {
  value = module.listener_and_routing
}

output "instance_id" {
  value = module.ec2.instance_ip_address
}


output "id" {
  value = module.ec2.id
}
