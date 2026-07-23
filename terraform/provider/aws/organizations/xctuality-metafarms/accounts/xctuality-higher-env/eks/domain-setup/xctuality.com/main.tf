module "acm" {
  source                    = "../../../../../modules/acm"
  subject_alternative_names = var.subject_alternative_names
  domain_name               = var.domain_name
  validation_method         = var.validation_method
  tags                      = var.tags

  create_before_destroy = var.create_before_destroy
}