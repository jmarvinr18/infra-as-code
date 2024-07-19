module "rsi-corp-td" {
    source = "../../../../../modules/aws/ecs/task-definition"
    app_task_family = "rsi-corp-service"
    execution_role_arn = "arn:aws:iam::891377256846:role/ECSTaskExecutionRole"
    container_definitions = "${path.module}/task-definition.json"
    cpu = 1024
}