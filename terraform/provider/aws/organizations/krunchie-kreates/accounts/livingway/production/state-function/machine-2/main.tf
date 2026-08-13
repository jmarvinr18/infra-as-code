module "role" {
  source = "../../../../../../../modules/step_functions/role"

  role_name = var.role_name

  inline_policies = [
    {
      name = "cloudwatch-logs"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogDelivery",
              "logs:GetLogDelivery",
              "logs:UpdateLogDelivery",
              "logs:DeleteLogDelivery",
              "logs:ListLogDeliveries",
              "logs:PutResourcePolicy",
              "logs:DescribeResourcePolicies",
              "logs:DescribeLogGroups"
            ]
            Resource = "*"
          }
        ]
      })
    }
  ]

  tags = var.tags
}

module "state_machine" {
  source = "../../../../../../../modules/step_functions/state_machine"

  name       = var.state_machine_name
  role_arn   = module.role.arn
  definition = file("${path.module}/definitions/state_machine.json")
  type       = var.type

  tags = var.tags
}
