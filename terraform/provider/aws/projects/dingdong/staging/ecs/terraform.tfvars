#### CLUSTER VALUES ####
app_cluster_name = "DINGDONG"
capacity_provider = ["EC2"]


#### SERVICE VALUES ####
launch_type      = "EC2"
service_name     = "dingdong-ecs-service"
td_name          = "dingdong-td"
cluster_name     = "DINGDONG"
ecs_role_name    = "ECSRole"
ecs_target_group = "ECSTARGETGROUP"

launch_template_name_prefix = "dingdong-"


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
ecs_service_policy_path = "./policies/ecs-service-role-policy.json"

assume_role_policy = "./policies/assume-role-policy.json"



#### EC2 INSTANCE VALUES ####

key_name               = "provisioner-key.pub"
key_path               = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/projects/dingdong/staging/ecs/.ssh"
key_pair               = ""
vpc_security_group_ids = ["sg-0afcc88276a07d362"]
amis                   = "ami-047126e50991d067b"
subnet_id              = "subnet-0e1f9878"
private_key            = "provisioner-key"
user                   = "ubuntu"
iam_instance_profile   = "ECSInstanceRole"



ami_from_instance_name = "DINGDONG-AMI"

tags = {
  "Name"        = "ECS-AGENT-DINGDONG"
  "Environment" = "PRODUCTION"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

asg_capacity_provider = [{
  name = "test-capacity"
  auto_scaling_group_provider = {
    auto_scaling_group_arn         = "arnasdfasdf"
    managed_termination_protection = "ENABLED"

    managed_scaling = {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}]



#### LOAD BALANCER VALUES ####

target_group_name          = "ECSTARGETGROUP"
instance_target_group_port = 8080

load_balancer_name = "DINGDONG-ALB"

health_check = {
  path                = "/admin/login"
  port                = 8080
  healthy_threshold   = 3
  unhealthy_threshold = 10
}

container_port = 8080
container_name = "dingdong-app"

certificate_arn = "arn:aws:acm:ap-southeast-1:339712823657:certificate/7b7effbc-faf5-4339-83f4-63a19c50dc8f"
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

asg_availability_zones = ["ap-southeast-1a"]

min_size = 0
max_size = 1
desired_capacity = 0
