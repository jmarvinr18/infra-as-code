module "ECSTaskExecutionRole" {

  source = "../../../../../modules/iam/role"

  assume_role_policy = var.assume_role_policy

  inline_policy = var.inline_policies_files

  role_name = "ECSTaskExecutionRole"

  tags = var.tags

}

module "ECSRole" {

  source = "../../../../../modules/iam/role"
  assume_role_policy = var.assume_role_policy
  role_name          = "ECSRole"

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = module.ECSRole.name

  tags = var.tags
}

module "ECSInstanceRole" {

  source = "../../../../../modules/iam/role"
  assume_role_policy = var.assume_role_policy
  role_name          = "ECSInstanceRole"


  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = module.ECSRole.name

  tags = var.tags
}

module "ECSAutoScalingRole" {

  source = "../../../../../modules/iam/role"
  assume_role_policy = var.assume_role_policy
  role_name          = "ECSAutoScalingRole"

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
  role       = module.ECSRole.name
   
  tags = var.tags

}

module "ServiceRoleForECS" {

  source = "../../../../../modules/iam/role"
  assume_role_policy = var.assume_role_policy
  role_name          = "ServiceRoleForECS"

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  role       = module.ECSRole.name

  tags = var.tags
}

module "ECSServiceRolePolicy" {
  source           = "../../../../../modules/iam/role_policy"
  name             = var.ecs_service_role_policy_name
  policy_file_name = var.ecs_service_policy_path
  role_id          = module.ServiceRoleForECS.id

}