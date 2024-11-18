
output "config_map_data_maproles" {
  value = data.kubernetes_config_map.aws-auth.data.mapRoles
}

output "aws_auth_configmap_data" {
  value     = local.aws_auth_configmap_data
  sensitive = false
}