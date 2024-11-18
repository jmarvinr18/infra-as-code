output "private_subnets" {
  value = data.aws_subnets.private.ids
}

output "public_subnets" {
  value = data.aws_subnets.public.ids
}

output "public_subnets_default" {
  value = data.aws_subnets.public_default.ids
}

output "vpc_id" {
  value = data.aws_vpc.selected.id
}

output "cidr_block" {
  value = data.aws_vpc.selected.cidr_block
}

output "subnets_az" {
  value = {
    for subnet in data.aws_subnet.subnets_az :
    format("%s", subnet.id) => format("%s", subnet.availability_zone)
  }
}

output "az_names" {
  value = [for subnet in data.aws_subnet.subnets_az : subnet.availability_zone]
}
