locals {
  stages = ["stg", "prd"]
  projects = [
    "toureast-gameplay",
  ]

  ecr_repositories = merge([
    for stage in local.stages : {
      for project in local.projects : format("%s-%s", stage, project) => {
        name = format("%s-%s", stage, project)
      }
    }
  ]...)
}
