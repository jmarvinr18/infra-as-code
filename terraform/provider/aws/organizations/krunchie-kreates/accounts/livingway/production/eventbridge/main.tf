resource "aws_lambda_permission" "this" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = module.rule.arn
}

module "rule" {
  source = "../../../../../../modules/eventbridge/rule"

  name           = var.rule_name
  description    = var.rule_description
  event_bus_name = var.event_bus_name
  event_pattern  = var.event_pattern
  state          = var.rule_state

  tags = var.tags
}

module "target" {
  source = "../../../../../../modules/eventbridge/target"

  rule_name      = module.rule.name
  target_id      = var.target_id
  arn            = var.lambda_function_arn
  event_bus_name = var.event_bus_name
}
