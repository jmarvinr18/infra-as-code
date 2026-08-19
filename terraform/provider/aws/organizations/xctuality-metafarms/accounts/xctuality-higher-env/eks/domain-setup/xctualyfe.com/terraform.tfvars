

domain_name               = "xctualyfe.com"
subject_alternative_names = ["*.xctualyfe.com"]
validation_method         = "DNS"

tags = {
  "Name"        = "xctuality-higher-env-acm"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

create_before_destroy = true


profile = "xctuality-higher-env"
region  = "ap-southeast-1"


