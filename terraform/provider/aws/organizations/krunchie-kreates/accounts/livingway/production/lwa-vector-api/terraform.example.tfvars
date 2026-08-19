client            = "livingway"
client_account_id = "000000000000"
environment       = "production"
region            = "ap-southeast-1"

name_prefix = "lwa-vector"

# Uses the default VPC and all of its subnets when left unset.
# vpc_id     = "vpc-xxxxxxxx"
# subnet_ids = ["subnet-aaaa", "subnet-bbbb"]

db_name                    = "vectordb"
db_instance_class          = "db.t4g.micro"
db_allocated_storage       = 20
db_backup_retention_period = 1

# false keeps the demo free of a Secrets Manager VPC endpoint; see variables.tf.
use_managed_master_password = false

# Owns a KMS key (~$1/mo) rather than depending on the AWS-managed aws/rds key,
# which may not exist yet in a fresh account. Set db_storage_encrypted = false
# for an unencrypted, entirely free demo instance.
# Public access for SQL clients (TablePlus, psql). Lock this to your own
# address: curl -s https://checkip.amazonaws.com
db_publicly_accessible = false
db_allowed_cidr_blocks = [] # e.g. ["203.0.113.4/32"] — 0.0.0.0/0 is rejected

db_storage_encrypted = true
db_create_kms_key    = true
# db_kms_key_id      = "arn:aws:kms:ap-southeast-1:000000000000:key/..."

# Postgres driver layer — build one per README.md, then paste the ARN here.
# layers = ["arn:aws:lambda:ap-southeast-1:000000000000:layer:psycopg:1"]

# cors_allow_origins = ["https://app.example.com"]

tags = {
  Owner = "platform"
}
