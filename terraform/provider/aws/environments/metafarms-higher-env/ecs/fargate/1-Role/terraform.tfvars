

tags = {
  "Name"        = "mtf-higher-stg"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}


profile = "metafarms-higher-env"
region  = "ap-southeast-1"


assume_role_policy      = "./policies/assume-role-policy.json"
ecs_service_policy_path = "./policies/ecs-service-role-policy.json"
ecs_service_role_policy_name = "ECSServiceRole"