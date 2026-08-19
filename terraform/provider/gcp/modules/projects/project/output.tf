output "projects" {
  value = google_project.this
}

output "project_ids" {
  value = {
    for env, project in google_project.this :
    env => project.project_id
  }
}

output "project_numbers" {
  value = {
    for env, project in google_project.this :
    env => project.number
  }
}
