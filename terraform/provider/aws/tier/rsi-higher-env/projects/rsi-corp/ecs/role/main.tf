
# module "rsi-sg" {
#   source              = "../../../../modules/aws/sg"
#   security_group_name = "RSI-SG"
#   ingress_rules = [{
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port   = 8080
#     to_port     = 8085
#     protocol    = "tcp"
#     description = "rsi-sg-test"
#     },
#     {
#       cidr_blocks = ["0.0.0.0/0"]
#       from_port   = 3306
#       to_port     = 3306
#       protocol    = "tcp"
#       description = "mysql connection"
#     }
#   ]

#   tags = {
#     "Name"        = "RSI-SG"
#     "Environment" = "staging"
#     "Release"     = "latest"
#     "Created-by"  = "jmarvinr"
#   }
# }

# data "local_file" "inline-policy" {
#   filename = "./inline-policy.json"
# }

# data "local_file" "inline_policy" {
#   for_each = var.inline_policies_files
#   filename = each.value
# }

# locals {
#   inline_policies = [for rule in data.local_file.inline_policy : jsondecode(rule.content)]
# }


module "ECSTaskExecutionRole" {

  source = "../../../../../../modules/iam/role"

  assume_role_policy = var.assume_role_policy

  inline_policy = var.inline_policies_files

  role_name = "ECSTaskExecutionRole"

}

module "ECSRole" {

  source = "../../../../../../modules/iam/role"
  assume_role_policy = var.assume_role_policy
  role_name = "ECSRole"

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role = module.ECSRole.name
}

module "ECSInstanceRole" {

  source = "../../../../../../modules/iam/role"
  assume_role_policy = var.assume_role_policy
  role_name = "ECSInstanceRole"


  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role = module.ECSRole.name

}

module "ECSAutoScalingRole" {

  source = "../../../../../../modules/iam/role"
  assume_role_policy = var.assume_role_policy
  role_name = "ECSAutoScalingRole"

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
  role = module.ECSRole.name

}

module "ServiceRoleForECS" {

  source = "../../../../../../modules/iam/role"
  assume_role_policy = var.assume_role_policy
  role_name = "ServiceRoleForECS"

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  role = module.ECSRole.name

}
