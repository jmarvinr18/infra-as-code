resource "aws_budgets_budget" "monthly_cost" {
  name         = var.budget_name
  budget_type  = var.budget_type
  limit_amount = tostring(var.monthly_limit)
  limit_unit   = var.limit_unit
  time_unit    = var.time_unit


  dynamic "notification" {
    for_each = [for rule in var.notifications : rule if rule.comparison_operator != ""]

    content {
        comparison_operator        = notification.value.comparison_operator
        threshold                  = notification.value.threshold
        threshold_type             = notification.value.threshold_type
        notification_type          = notification.value.notification_type
        subscriber_email_addresses = notification.value.subscriber_email_addresses
    }
  }

}