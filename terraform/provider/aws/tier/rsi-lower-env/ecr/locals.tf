locals {
  stages = ["dev", "sit", "uat"]
  projects = [
    "kunzite-api",
    "inderite-api",
    "rhodonite-api",
    "creedite-api",
    "jasper-api",
    "amethyst-api",
    "sardonyx-api",
    "spinel-web",
    "algodonite-admin-web",
    "algodonite-agent-web",
    "obsidian-app",
    "rutile-api"
  ]

  ecr_repositories = merge([
    for stage in local.stages : {
      for project in local.projects : format("%s-%s", stage, project) => {
        name = format("%s-%s", stage, project)
      }
    }
  ]...)
}
