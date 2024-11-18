locals {
  stages = ["stg", "prd"]
  projects = [
    "rhodochrosite-admin-api",
    "rhodizite-web",
  ]

  ecr_repositories = merge([
    for stage in local.stages : {
      for project in local.projects : format("%s-%s", stage, project) => {
        name = format("%s-%s", stage, project)
      }
    }
  ]...)
}
