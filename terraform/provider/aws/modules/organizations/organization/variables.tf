variable "feature_set" {
  type = string
}
variable "aws_service_access_principals" {
  type = list(string)
  default = [
    "sso.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]
}

variable "enabled_policy_types" {
    type = list(string)
    default = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
  ]
}