locals {
  name = var.name == "" ? format("%s-%s-%s", var.env, var.tier, var.region) : var.name
  common = {
    "Tier"        = lower(var.tier)
    "Env"         = lower(var.env)
    "Purpose"     = lower(var.purpose)
    "Provisioner" = lower(var.provisioner)
  }

  required = var.name == "" ? local.common : merge(local.common, { "Name" = lower(var.name) })

}