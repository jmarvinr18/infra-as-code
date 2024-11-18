
resource "aws_iam_role" "lambda-rds-actions-role" {
  name = "LambdaServerUpdatesRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  ]
}


resource "aws_lambda_function" "lambda-rds-actions" {

  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout

  role          = aws_iam_role.lambda-rds-actions-role.arn


  environment {
    variables = var.environment.variables    
  }

  filename      = data.archive_file.lambda_function_archive.output_path
  source_code_hash = data.archive_file.lambda_function_archive.output_base64sha256
}


resource "aws_lambda_permission" "rds-scheduler-eventrulelive-allow" {
  statement_id  = "AllowExecutionFromEventRuleLive"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-rds-actions.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds-scheduler-rule_live.arn
}


resource "aws_lambda_permission" "rds-scheduler-eventruledown-allow" {
  statement_id  = "AllowExecutionFromEventRuleDown"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-rds-actions.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds-scheduler-rule_down.arn
}



resource "aws_cloudwatch_event_rule" "rds-scheduler-rule_down" {
  name        = "rds-scheduler-rule_down"
  description = "EventBridge Rule For RDS Cluster Schedule Updates"
  schedule_expression = "cron(1 16 * * ? *)" 
  
  event_pattern = <<PATTERN
{
  "source": ["aws.events"],
  "detail-type": ["Scheduled Event"],
  "resources": ["*"],
  "detail": {
    "MODE_UPDATE": ["downtime"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "rds-scheduler-rule_down_target" {
  rule      = aws_cloudwatch_event_rule.rds-scheduler-rule_down.name
  target_id = "RDSSchedulerEventRuleDownTarget"
  arn = aws_lambda_function.lambda-rds-actions.arn
}


resource "aws_cloudwatch_event_rule" "rds-scheduler-rule_live" {
  name        = "rds-scheduler-rule_live"
  description = "EventBridge Rule For RDS Cluster Schedule Updates"
  schedule_expression = "cron(30 22 * * ? *)" 
  
  event_pattern = <<PATTERN
{
  "source": ["aws.events"],
  "detail-type": ["Scheduled Event"],
  "resources": ["*"],
  "detail": {
    "MODE_UPDATE": ["live"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "rds-scheduler-rule_live_target" {
  rule      = aws_cloudwatch_event_rule.rds-scheduler-rule_live.name
  target_id = "RDSSchedulerEventRuleDownTarget"
  arn = aws_lambda_function.lambda-rds-actions.arn
}

