terraform {
  required_version = "~> 1.3"

  backend "s3" {
    bucket = "wl-higher-tf-state"
    key    = "spdr88-tf-state/terraform.tfstate"
    region = "ap-east-1"
    # dynamodb_table = "ccTfDemo"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

# module "tf-state" {
#   source        = "../../../../modules/aws/ecs/cluster"
# }

module "ecs-cluster" {
  source                         = "../../../../modules/aws/ecs/cluster"
  app_cluster_name               = local.app_cluster_name
  availability_zones             = local.availability_zones

  ecr_repo_url                   = local.repo_url
  container_port                 = local.container_port
  app_task_name                  = local.app_task_name
  ecs_task_execution_role_name   = local.ecs_task_execution_role_name
  application_load_balancer_name = local.application_load_balancer_name
  target_group_name              = local.target_group
  app_service_name               = local.app_service_name
}

module "ecs-taskdefinition" {
  source = "../../../../modules/aws/ecs/container-definition"
  app_task_family                = local.app_task_family
}