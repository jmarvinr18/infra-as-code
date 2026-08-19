#### ROLE VALUES ####

inline_policies_files = [
  {
    name = "ECSS3Policy",
    file = "./policies/ecs-s3-policy.json",
  },
  {
    name = "TaskExecutionRolePolicy",
    file = "./policies/task-execution-role-policy.json",
  },
  {
    name = "DockerHubSecretsPolicy",
    file = "./policies/docker-hub-secrets-policy.json",
  },

]

ecs_service_role_policy_name = "ECSServiceRolePolicy"
ecs_service_policy_path      = "./policies/ecs-service-role-policy.json"

assume_role_policy = "./policies/assume-role-policy.json"

profile = "xctuality"
region  = "ap-southeast-1"

tags = {
  "Name"        = "ECS-RESOURCE-DINGDONG"
  "Environment" = "PRODUCTION"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

