# Create the organization with all features enabled.
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  # Enable the AWS services you want to manage org-wide.
  aws_service_access_principals = var.aws_service_access_principals

  enabled_policy_types = var.enabled_policy_types
}