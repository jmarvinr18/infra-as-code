module "rsi-corp-td" {
    source = "../../../../../../modules/ecs/task-definition"
    app_task_family = "rsi-corp-td"
    execution_role_arn = "arn:aws:iam::339712823657:role/ECSTaskExecutionRole"
    container_definitions = "${path.module}/task-definition.json"
    # requires_compatibilities = 
    cpu = 1024
}