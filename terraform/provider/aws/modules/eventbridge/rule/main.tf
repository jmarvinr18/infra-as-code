resource "aws_cloudwatch_event_rule" "this" {
  name                = var.name
  description         = var.description
  event_bus_name      = var.event_bus_name
  event_pattern       = var.event_pattern
  schedule_expression = var.schedule_expression
  state               = var.state

  tags = var.tags
}
