client            = "livingway"
client_account_id = "792682046440"
environment       = "production"
region            = "ap-southeast-1"

role_name = "lwa-glue-dq-role"

s3_bucket = "lwa-rag-documents"
s3_prefix = "processed/"

database_name        = "lwa_ingest"
database_description = "Glue catalog database for LWA document ingestion pipeline."

table_name = "processed"

ruleset_name = "lwa_processed_quality"
ruleset      = <<-DQDL
  Rules = [
    ColumnExists "document_id",
    ColumnExists "source_key",
    ColumnExists "processed_at",
    ColumnExists "status",
    Completeness "document_id" >= 0.99,
    Completeness "source_key" >= 0.99,
    Completeness "status" >= 0.99,
    Uniqueness "document_id" >= 0.95,
    ColumnValues "status" in ["success", "quarantined"]
  ]
DQDL

tags = {
  "Name"       = "livingway-glue-data-quality"
  "Client"     = "livingway"
  "Created-by" = "terraform-jmr"
}
