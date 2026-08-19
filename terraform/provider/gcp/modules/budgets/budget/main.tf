resource "google_monitoring_notification_channel" "this" {
  for_each = toset(var.notification_emails)

  project      = var.monitoring_project
  display_name = format("%s - %s", var.budget_name, each.value)
  type         = "email"

  labels = {
    email_address = each.value
  }
}

resource "google_billing_budget" "monthly_cost" {
  billing_account = var.billing_account
  display_name    = var.budget_name

  budget_filter {
    # Empty covers every project under the billing account.
    projects        = length(var.projects) > 0 ? var.projects : null
    calendar_period = var.calendar_period
  }

  amount {
    specified_amount {
      currency_code = var.limit_unit
      units         = tostring(var.monthly_limit)
    }
  }

  dynamic "threshold_rules" {
    for_each = [for rule in var.notifications : rule if rule.spend_basis != ""]

    content {
      threshold_percent = threshold_rules.value.threshold_percent
      spend_basis       = threshold_rules.value.spend_basis
    }
  }

  all_updates_rule {
    monitoring_notification_channels = concat(
      [for channel in google_monitoring_notification_channel.this : channel.id],
      var.additional_notification_channels
    )

    # false keeps the built in billing admin recipients active alongside
    # the custom channels above.
    disable_default_iam_recipients = var.disable_default_iam_recipients
  }
}
