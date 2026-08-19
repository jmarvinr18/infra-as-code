feature_set = "ALL"

clients = {
  # "acme-prod" = {
  #   email       = "aws+acme-prod@krunchie.com"
  #   environment = "prod"
  # }
  # "acme-staging" = {
  #   email       = "aws+acme-staging@krunchie.com"
  #   environment = "staging"
  # }
  # "globex-prod" = {
  #   email       = "aws+globex-prod@krunchie.com"
  #   environment = "prod"
  # }
  "jmr-studios" = {
    email       = "jmarvin.ramoda+22@gmail.com"
    environment = "prod"
  }  
  "lwa-digital" = {
    email       = "jmarvin.ramoda+lwa@gmail.com"
    environment = "prod"
  }    
}

close_on_deletion = true
iam_user_access_to_billing = "ALLOW"
role_name = "OrganizationAccountAccessRole"


name = "clients-baseline-guardrail"
description = "Restrict client accounts to approved regions and block root usage."
type = "SERVICE_CONTROL_POLICY"
content = "./policies/scp.json"

