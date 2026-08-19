#### CLUSTER VALUES ####
app_cluster_name  = "DINGDONG-PRODUCTION"
capacity_provider = ["EC2"]


#### SERVICE VALUES ####
launch_type      = "EC2"
service_name     = "dingdong-ecs-service"
td_name          = "dingdong-td"
cluster_name     = "DINGDONG-PRODUCTION"
ecs_role_name    = "ECSRole"
ecs_target_group = "ECSTARGETGROUP"
network_mode = "host"

asg_capacity_provider = [{
  name = "test-capacity"
  auto_scaling_group_provider = {
    auto_scaling_group_arn         = "arn:aws:elasticloadbalancing:ap-southeast-1:664812007902:targetgroup/ECSTARGETGROUP/50a561253e2c197b"
    managed_termination_protection = "ENABLED"

    managed_scaling = {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}]

container_port = 3000
container_name = "dingdong-production-app"


tags = {
  "Name"        = "ECS-RESOURCE-DINGDONG"
  "Environment" = "PRODUCTION"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

profile = "xctuality"
region  = "ap-southeast-1"