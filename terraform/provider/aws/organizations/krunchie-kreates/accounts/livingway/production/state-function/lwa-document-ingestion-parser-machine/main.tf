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
    },
    {
      name = "s3-source-bucket"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "S3ReadSourceFiles"
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:GetObjectVersion"
            ]
            Resource = "arn:aws:s3:::${var.source_s3_bucket}/*"
          },
          {
            Sid    = "S3WriteTranscribeOutput"
            Effect = "Allow"
            Action = [
              "s3:PutObject"
            ]
            Resource = "arn:aws:s3:::${var.source_s3_bucket}/*"
          }
        ]
      })
    },
    {
      name = "ai-service-integrations"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "TextractAccess"
            Effect = "Allow"
            Action = [
              "textract:StartDocumentTextDetection",
              "textract:GetDocumentTextDetection"
            ]
            Resource = "*"
          },
          {
            Sid    = "RekognitionAccess"
            Effect = "Allow"
            Action = [
              "rekognition:DetectLabels"
            ]
            Resource = "*"
          },
          {
            Sid    = "TranscribeAccess"
            Effect = "Allow"
            Action = [
              "transcribe:StartTranscriptionJob",
              "transcribe:GetTranscriptionJob"
            ]
            Resource = "*"
          }
        ]
      })
    },
    {
      name = "pipeline-integrations"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "LambdaInvoke"
            Effect = "Allow"
            Action = [
              "lambda:InvokeFunction"
            ]
            Resource = [
              var.lambda_function_arn,
              "${var.lambda_function_arn}:*"
            ]
          },
          {
            Sid    = "GlueDataQuality"
            Effect = "Allow"
            Action = [
              "glue:StartDataQualityRulesetEvaluationRun",
              "glue:GetDataQualityRulesetEvaluationRun",
              "glue:GetDataQualityRuleset",
              "glue:GetTable",
              "glue:GetDatabase",
              "glue:GetPartitions"
            ]
            Resource = "*"
          },
          {
            Sid    = "PassGlueRole"
            Effect = "Allow"
            Action = "iam:PassRole"
            Resource = var.glue_execution_role_arn
            Condition = {
              StringEquals = {
                "iam:PassedToService" = "glue.amazonaws.com"
              }
            }
          },
          {
            Sid    = "CloudWatchMetrics"
            Effect = "Allow"
            Action = [
              "cloudwatch:PutMetricData"
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
