locals {
  admins     = [for user in var.admins : user]
  developers = [for user in var.developers : user]
  developers_kms_keys_arn = flatten([for i in var.developers_kms_keys : [
    for k, v in data.aws_kms_alias.developers_kms_keys[i] : v if k == "arn"
  ]])
  users = toset(concat(sort(local.admins), sort(local.developers)))
}
