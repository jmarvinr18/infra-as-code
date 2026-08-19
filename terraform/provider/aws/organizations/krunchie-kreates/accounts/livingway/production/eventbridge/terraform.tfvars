client            = "livingway"
client_account_id = "792682046440"
environment       = "production"
region            = "ap-southeast-1"

rule_name        = "lwa-s3-document-upload"
rule_description = "Triggers lwaDocumentProcessor Lambda when a file is uploaded to the lwa-rag-documents S3 bucket."
event_bus_name   = "default"
rule_state       = "ENABLED"

event_pattern = <<-JSON
  {
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "detail": {
      "bucket": {
        "name": ["lwa-rag-documents"]
      }
    }
  }
JSON

target_id            = "livingway-document-ingestion-parser-machine"
lambda_function_arn  = "arn:aws:states:ap-southeast-1:792682046440:stateMachine:livingway-document-ingestion-parser-machine"
lambda_function_name = "lwaDocumentProcessor"

tags = {
  "Name"       = "lwa-s3-document-upload"
  "Client"     = "livingway"
  "Created-by" = "terraform-jmr"
}
