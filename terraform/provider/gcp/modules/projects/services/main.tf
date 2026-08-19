locals {
  # one entry per project/api pair so a single for_each covers every project.
  services = merge([
    for env, project_id in var.project_ids : {
      for service in var.services : format("%s-%s", env, service) => {
        project_id = project_id
        service    = service
      }
    }
  ]...)
}

resource "google_project_service" "this" {
  for_each = local.services

  project = each.value.project_id
  service = each.value.service

  # Keep false so a destroy does not fail trying to disable apis on a
  # project that is going away in the same run.
  disable_on_destroy         = var.disable_on_destroy
  disable_dependent_services = var.disable_dependent_services
}
