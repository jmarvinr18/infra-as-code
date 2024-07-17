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

assume_role_policy = "./policies/assume-role-policy.json"
