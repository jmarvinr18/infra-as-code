

domain_name               = "xctuality.com"
subject_alternative_names = ["*.xctuality.com"]
validation_method         = "DNS"

tags = {
  "Name"        = "xct-prd-toureast"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

create_before_destroy = true


profile = "xctuality-higher-env"
region  = "ap-southeast-1"


