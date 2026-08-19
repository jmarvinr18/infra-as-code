

domain_name               = "metafarms.io"
subject_alternative_names = ["*.metafarms.io"]
validation_method         = "DNS"

tags = {
  "Name"        = "mtf-prd-metafarms"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

create_before_destroy = true


profile = "metafarms-higher-env"
region  = "ap-southeast-1"


