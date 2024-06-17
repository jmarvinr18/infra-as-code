
resource "aws_ecs_task_definition" "app_task" {
  family                   = var.app_task_family
  container_definitions    = <<DEFINITION
  [
            {
                "name": "spdr88-app",
                "image": "aslitechnologies/obsidian:app",
                "repositoryCredentials": {
                    "credentialsParameter": "arn:aws:secretsmanager:ap-southeast-1:104869295404:secret:DockerHubSecret-abvFY5"
                },
                "cpu": 0,
                "portMappings": [
                    {
                        "name": "spdr88-app-8080-tcp",
                        "containerPort": 8080,
                        "hostPort": 8080,
                        "protocol": "tcp",
                        "appProtocol": "http"
                    }
                ],
                "essential": true,
                "environment": [],
                "environmentFiles": [
                    {
                        "value": "arn:aws:s3:::spdr88-higher/.env",
                        "type": "s3"
                    }
                ],
                "mountPoints": [
                    {
                        "sourceVolume": "app",
                        "containerPath": "/var/www/html",
                        "readOnly": false
                    }
                ],
                "volumesFrom": [],
                "workingDirectory": "/var/www/html",
                "ulimits": [],
                "logConfiguration": {
                    "logDriver": "awslogs",
                    "options": {
                        "awslogs-create-group": "true",
                        "awslogs-group": "/ecs/spdr88-td",
                        "awslogs-region": "ap-southeast-1",
                        "awslogs-stream-prefix": "ecs"
                    },
                    "secretOptions": []
                },
                "systemControls": []
            }
  ]
  DEFINITION
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

}
