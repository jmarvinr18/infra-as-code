

budget_name   = "orobo-tech-monthly-100"
monthly_limit = 100
limit_unit    = "USD"

app         = "orobo"
environment = "shared"
region      = "asia-southeast1"

monitoring_project = "orobo-shared"

# Fill in once the billing account is visible. See NOTES.md, "Open blocker".
billing_account = ""

# Empty covers all three orobo projects under the billing account.
projects = []

notification_emails = ["jmarvin.ramoda@gmail.com"]


notifications = [
  {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  },
  {
    threshold_percent = 0.8
    spend_basis       = "CURRENT_SPEND"
  },
  {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }
]
