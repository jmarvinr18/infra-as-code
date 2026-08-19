output "services" {
  value = {
    for env, project_id in var.project_ids :
    env => [
      for service in google_project_service.this :
      service.service if service.project == project_id
    ]
  }
}
