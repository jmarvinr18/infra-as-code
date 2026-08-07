module "ses" {
  source = "../../../../../../modules/ses"

  domain                        = var.domain
  mail_from_subdomain           = var.mail_from_subdomain
  mail_from_mx_failure_behavior = var.mail_from_mx_failure_behavior

  create_configuration_set = var.create_configuration_set
  configuration_set_name   = var.configuration_set_name

  smtp_iam_user_name = var.smtp_iam_user_name
  tags               = var.tags
}
