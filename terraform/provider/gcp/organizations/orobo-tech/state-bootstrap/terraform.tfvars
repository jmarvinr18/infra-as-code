
bucket_name = "orobo-tech-tfstate"
project     = "orobo-shared"
location    = "ASIA-SOUTHEAST1"
region      = "asia-southeast1"

uniform_bucket_level_access = true
public_access_prevention    = "enforced"
versioning                  = true

labels = {
  "name"       = "orobo-tech"
  "app"        = "orobo"
  "created-by" = "terraform-jmr"
}
