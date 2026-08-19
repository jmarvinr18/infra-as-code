client            = "livingway"
client_account_id = "792682046440"
environment       = "production"
region            = "ap-southeast-1"

domain              = "livingwayapostolics.org"
mail_from_subdomain = "mail"

create_configuration_set = true
configuration_set_name   = "livingway-production"

smtp_iam_user_name = "livingway-ses-smtp"

tags = {
  "Name"       = "livingway-ses"
  "Client"     = "livingway"
  "Created-by" = "terraform-jmr"
}
