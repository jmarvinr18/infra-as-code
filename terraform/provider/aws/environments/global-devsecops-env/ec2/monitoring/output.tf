output "existing_sg_id" {
  value = data.aws_security_groups.existing_sg.id
}

output "public_dns" {
  value = module.ec2.public_dns
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "content" {
  value = module.cloudflare.content
}

output "hostname" {
  value = module.cloudflare.hostname
}
output "id" {
  value = module.cloudflare.id
}
output "name" {
  value = module.cloudflare.name
}