resource "helm_release" "this" {

  for_each = {for i, release in var.helm_releases : i => release}

  name = each.value.helm_release_name

  repository = each.value.helm_repository
  chart      = each.value.chart
  namespace  = each.value.namespace
  version    = each.value.helm_version

  values     = each.value.helm_values

}