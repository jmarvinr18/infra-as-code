locals {


  aws_auth_maproles = {
    mapRoles = <<-EOT
        ${data.kubernetes_config_map.aws-auth.data.mapRoles}
        ${templatefile("${path.module}/templates/maproles.tpl", {
    caller_identity = data.aws_caller_identity.this.id
    roles           = var.roles
    cluster_name    = var.cluster
})}
    EOT
}

aws_auth_mapusers = {
  mapUsers = <<-EOT
        ${templatefile("${path.module}/templates/mapusers.tpl", {
  caller_identity = data.aws_caller_identity.this.id
  devs            = var.devs
  admins          = var.admins
})}
    EOT
}

aws_auth_configmap_data = {
  mapRoles = local.aws_auth_maproles.mapRoles
  mapUsers = local.aws_auth_mapusers.mapUsers
}

}