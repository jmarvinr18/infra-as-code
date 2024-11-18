data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}
data "aws_iam_role" "this" {
  name = var.ecs_role_name
}

data "aws_ecs_task_definition" "this" {
  task_definition = var.td_name
}

data "aws_alb_target_group" "this" {
    name = var.ecs_target_group
}

module "ecs-service" {
    source = "../../../../../../modules/ecs/service"

    name = var.service_name
    aws_ecs_cluster_id = data.aws_ecs_cluster.this.id
    aws_ecs_task_definition_arn = data.aws_ecs_task_definition.this.arn
    iam_role_arn = "arn:aws:iam::339712823657:role/ECSRole"
    target_group_arn = data.aws_alb_target_group.this.arn
    launch_type = var.launch_type
    # depends_on = [  ]
}