client            = "livingway"
client_account_id = "792682046440"
environment       = "production"
region            = "ap-southeast-1"

state_machine_name = "livingway-document-ingestion-parser-machine"
role_name          = "livingway-machine-1-role"
type               = "STANDARD"

source_s3_bucket        = "lwa-rag-documents"
lambda_function_arn     = "arn:aws:lambda:ap-southeast-1:792682046440:function:lwaDocumentProcessor"
glue_execution_role_arn = "arn:aws:iam::792682046440:role/lwa-glue-dq-role"

tags = {
  "Name"       = "livingway-machine-1"
  "Client"     = "livingway"
  "Created-by" = "terraform-jmr"
}
