output "name" {
  value = google_billing_budget.monthly_cost.name
}

output "id" {
  value = google_billing_budget.monthly_cost.id
}

output "display_name" {
  value = google_billing_budget.monthly_cost.display_name
}

output "notification_channels" {
  value = {
    for email, channel in google_monitoring_notification_channel.this :
    email => channel.id
  }
}
