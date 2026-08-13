variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "client" {
  type = string
}

variable "client_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "role_name" {
  type = string
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket containing the processed documents."
}

variable "s3_prefix" {
  type        = string
  description = "S3 prefix (folder) within the bucket. Must end with /."
  default     = "processed/"
}

variable "database_name" {
  type = string
}

variable "database_description" {
  type    = string
  default = ""
}

variable "table_name" {
  type = string
}

variable "table_columns" {
  type = list(object({
    name = string
    type = string
  }))
  default = [
    { name = "document_id",   type = "string" },
    { name = "source_bucket", type = "string" },
    { name = "source_key",    type = "string" },
    { name = "document_type", type = "string" },
    { name = "content",       type = "string" },
    { name = "entities",      type = "string" },
    { name = "key_phrases",   type = "string" },
    { name = "sentiment",     type = "string" },
    { name = "labels",        type = "string" },
    { name = "processed_at",  type = "string" },
    { name = "status",        type = "string" },
  ]
}

variable "ruleset_name" {
  type = string
}

variable "ruleset" {
  type        = string
  description = "DQDL ruleset definition."
}

variable "tags" {
  type    = map(string)
  default = {}
}
