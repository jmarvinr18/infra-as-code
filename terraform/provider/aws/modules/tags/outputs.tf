output "required" {
  value = merge(
    local.required,
    var.additional
  )
}

output "name" {
  value = local.name
}