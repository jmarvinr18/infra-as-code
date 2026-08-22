client            = "aiteam-prmj"
client_account_id = "792682046440"
environment       = "production"
region            = "ap-southeast-1"

name_prefix = "aiteam-prmj-tracker"

# Uses the default VPC and all of its subnets when left unset.
vpc_id     = "vpc-01444b6a823bd52b0"
subnet_ids = ["subnet-0b450de5bd160f51e", "subnet-095eebf4dcc799429", "subnet-070d2bd48e49801f3"]

db_name                    = "vectordb"
db_instance_class          = "db.t4g.micro"
db_allocated_storage       = 20
db_backup_retention_period = 1

stage_name = "develop"

db_kms_key_id = "arn:aws:kms:ap-southeast-1:792682046440:key/a4c0a651-fc82-4427-aaf5-3e0b2c7ac1d8"

# false keeps the demo free of a Secrets Manager VPC endpoint; see variables.tf.
use_managed_master_password = false

# Postgres driver layer — build one per README.md, then paste the ARN here.
# layers = ["arn:aws:lambda:us-east-1:000000000000:layer:psycopg:1"]

# cors_allow_origins = ["https://app.example.com"]

# Optional. A private API can be created without associating specific endpoints.
# api_gateway_vpc_endpoint_ids = ["vpce-..."]

tags = {
  "Name"       = "aiteam-prmj"
  "Release"    = "latest"
  "Created-by" = "tf-jmarvinr"
}

# This VPC has no Internet Gateway, so RDS must remain private.
db_publicly_accessible = false
db_allowed_cidr_blocks = []
