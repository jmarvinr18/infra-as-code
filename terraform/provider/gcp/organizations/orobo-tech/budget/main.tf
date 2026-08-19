

module "budget" {
  source = "../../../modules/budgets/budget"

  budget_name     = var.budget_name
  billing_account = var.billing_account

  monthly_limit = var.monthly_limit
  limit_unit    = var.limit_unit

  monitoring_project  = var.monitoring_project
  notification_emails = var.notification_emails

  # Empty covers every project under the billing account, which is all three
  # orobo projects today. Split per project once that stops being true.
  projects = var.projects

  notifications = var.notifications

  # Keep the built in billing admin recipients alongside the email channels.
  disable_default_iam_recipients = false
}
