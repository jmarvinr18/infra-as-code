resource "aws_sfn_state_machine" "this" {
  name       = var.name
  role_arn   = var.role_arn
  definition = var.definition
  type       = var.type

  dynamic "logging_configuration" {
    for_each = var.logging_configuration != null ? [var.logging_configuration] : []
    content {
      log_destination        = logging_configuration.value.log_destination
      include_execution_data = logging_configuration.value.include_execution_data
      level                  = logging_configuration.value.level
    }
  }

  tags = var.tags
}
