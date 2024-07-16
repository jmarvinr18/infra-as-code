module "rsi-corp" {
  source           = "../../../../modules/aws/ecs/cluster"
  app_cluster_name = "test"

  capacity_provider = ["FARGATE"]
}

module "rsi-sg" {
  source              = "../../../../modules/aws/sg"
  security_group_name = "RSI-SG"
  ingress_rules = [{
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8085
    protocol    = "tcp"
    description = "rsi-sg-test"
    },
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "mysql connection"
    }
  ]

  tags = {
    "Name"        = "RSI-SG"
    "Environment" = "staging"
    "Release"     = "latest"
    "Created-by"  = "jmarvinr"
  }
}

data "local_file" "policy" {
  filename = "./policy.json"
}
data "local_file" "inline-policy" {
  filename = "./inline-policy.json"
}

module "my-role" {
    source = "../../../../modules/aws/iam/role"
    role_name = "ECS-ROLE"
    policy = jsondecode(data.local_file.policy.content)

    inline_policy_name = "name"

    inline_policy = jsondecode(data.local_file.inline-policy.content)


}