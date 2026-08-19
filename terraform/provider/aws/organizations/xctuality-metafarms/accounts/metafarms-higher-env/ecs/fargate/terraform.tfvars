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

profile = "metafarms-higher-env"
region  = "ap-southeast-1"

tags = {
  "Name"        = "metafarms-higher-env-ecs"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}


#### CLUSTER VALUES ####
app_cluster_name  = "METAFARMS_PRODUCTION"
capacity_provider = ["FARGATE"]

#### LOAD BALANCER VALUES ####

target_group_name     = "METAFARMSPRODTG"
target_group_port     = 80
target_group_protocol = "HTTP"
target_type = "ip"

instance_target_group_port = 9090

load_balancer_name = "METAFARMSPRODALB"

health_check = {
  path                = "/sign-in"
  port                = 9090
  healthy_threshold   = 3
  unhealthy_threshold = 10
}

certificate_arn = "arn:aws:acm:ap-southeast-1:347620126556:certificate/55c622f5-3a22-4bb0-9d3c-64c6d49a5edb"
ssl_policy      = "ELBSecurityPolicy-2016-08"

elb_listeners = [
  {
    port     = "80"
    protocol = "HTTP"

    default_action = {
      type = "redirect"

      redirect = {
        port                 = "443"
        protocol             = "HTTPS"
        redirect_status_code = "HTTP_301"
      }
    }
  },
  {
    port     = "443"
    protocol = "HTTPS"

    default_action = {
      type = "forward"
      redirect = {
        port                 = null
        protocol             = null
        redirect_status_code = null
      }
    }
  },
]


vpc_name = "metafarms-higher-env-vpc"
# Security Group Variables
security_group_name = "metafarms-higher-env-sg"

ingress_rules = [
  {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }
]

#### TASK DEFINITION VALUES ####
td_name          = "metafarms-td"
network_mode = "awsvpc"

cpu = 2048
memory = 4096


#### SERVICE VALUES ####
launch_type  = "FARGATE"
service_name = "metafarms-ecs-service"
scheduling_strategy = "REPLICA"
desired_count = 1

cluster_name   = "METAFARMS_PRODUCTION"
container_port = 9090
container_name = "metafarm-fe-stg"


#### AUTO-SCALING VALUES ####

min_capacity = 1
max_capacity = 2
aws_appautoscaling_policy_name = "test-app-autoscaling-policy"
policy_type = "TargetTrackingScaling"