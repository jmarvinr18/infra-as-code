client            = "livingway"
client_account_id = "792682046440"
environment       = "production"
region            = "ap-southeast-1"

name_prefix = "lwaagenttracker"

# Uses the default VPC and all of its subnets when left unset.
# vpc_id     = "vpc-xxxxxxxx"
# subnet_ids = ["subnet-aaaa", "subnet-bbbb"]

db_name                    = "vectordb"
db_instance_class          = "db.t4g.micro"
db_allocated_storage       = 20
db_backup_retention_period = 1

stage_name = "develop"

# false keeps the demo free of a Secrets Manager VPC endpoint; see variables.tf.
use_managed_master_password = false

# Postgres driver layer — build one per README.md, then paste the ARN here.
# layers = ["arn:aws:lambda:ap-southeast-1:000000000000:layer:psycopg:1"]

# cors_allow_origins = ["https://app.example.com"]

tags = {
  Owner = "platform"
}

# Public access for TablePlus. Locked to this workstation's current public IP —
# re-run `curl -s https://checkip.amazonaws.com` and update if your ISP moves it.
db_publicly_accessible = true
db_allowed_cidr_blocks = ["138.84.139.164/32"]
