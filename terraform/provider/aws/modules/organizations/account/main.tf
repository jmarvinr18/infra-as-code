resource "aws_organizations_account" "this" {
  for_each = var.clients

  name      = each.key
  email     = each.value.email
  parent_id = var.parent_id

  # Auto-created admin role the management account can assume.
  role_name = var.role_name

  # Recommended: keep IAM billing access on, and don't let Terraform
  # try to close the account on destroy without you noticing.

  iam_user_access_to_billing = var.iam_user_access_to_billing
  close_on_deletion          = var.close_on_deletion

  tags = {
    Client      = split("-", each.key)[0]
    Environment = each.value.environment
    ManagedBy   = "terraform"
  }

  lifecycle {
    # Email/name changes require account recreation; guard against accidents.
    ignore_changes = [role_name]
  }
}