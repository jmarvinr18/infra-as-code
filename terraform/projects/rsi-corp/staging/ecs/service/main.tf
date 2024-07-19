data "aws_ecs_cluster" "this" {
  cluster_name = "default"
}
data "aws_iam_role" "this" {
  name = "ECSRole"
}

data "aws_ecs_task_definition" "rsi-corp" {
  task_definition = "rsi-corp-service"
}

data "aws_alb_target_group" "this" {
    name = "ECSTARGETGROUP"
}

module "ecs-service" {
    source = "../../../../../modules/aws/ecs/service"

    name = "test-service"
    aws_ecs_cluster_id = data.aws_ecs_cluster.this.id
    aws_ecs_task_definition_arn = data.aws_ecs_task_definition.rsi-corp.arn
    iam_role_arn = data.aws_iam_role.this.arn
    target_group_arn = data.aws_alb_target_group.this.arn
    depends_on = [  ]
}