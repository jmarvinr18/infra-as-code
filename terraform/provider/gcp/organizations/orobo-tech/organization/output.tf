output "project_ids" {
  value = module.projects.project_ids
}

output "project_numbers" {
  value = module.projects.project_numbers
}

output "budget_projects" {
  description = "project numbers formatted for the budget filter"
  value = [
    for number in module.projects.project_numbers :
    format("projects/%s", number)
  ]
}

output "services" {
  value = module.services.services
}
