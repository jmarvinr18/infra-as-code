

module "budget" {
  source = "../../../../../../modules/budgets/budget"
  budget_name = var.budget_name
  monthly_limit = var.monthly_limit
  time_unit = var.time_unit

  budget_type = var.budget_type
  limit_unit = var.limit_unit

  notifications = var.notifications
}