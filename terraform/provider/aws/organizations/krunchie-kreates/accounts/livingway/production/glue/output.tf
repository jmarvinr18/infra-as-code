output "database_name" {
  value = module.database.name
}

output "table_name" {
  value = module.table.name
}

output "ruleset_name" {
  value = module.ruleset.name
}

output "ruleset_arn" {
  value = module.ruleset.arn
}

output "role_arn" {
  value = module.role.arn
}
