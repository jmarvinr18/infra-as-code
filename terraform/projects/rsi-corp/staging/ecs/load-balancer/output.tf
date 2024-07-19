
output "subnets_out" {
  value = [data.aws_subnets.selected.ids]
}

output "load_balancer_info" {
  value = module.load-balancer
}

output "target_group" {
  value = module.target-group
}

output "listener_and_routing" {
  value = module.listener-and-routing
}

output "instance" {
  value = data.aws_instance.this
}