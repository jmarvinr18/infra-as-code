locals {
  name = var.name == "" ? format("%s-%s-%s", var.app, var.env, var.region) : var.name
  common = {
    "env"         = lower(var.env)
    "app"         = lower(var.app)
    "purpose"     = lower(var.purpose)
    "provisioner" = lower(var.provisioner)
  }

  required = var.name == "" ? local.common : merge(local.common, { "name" = lower(var.name) })

}
