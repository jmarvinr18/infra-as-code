
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}


variable "block_public_acls" {
  type = bool
}

variable "block_public_policy" {
  type = bool
}

variable "ignore_public_acls" {
  type = bool
}

variable "restrict_public_buckets" {
  type = bool
}

variable "ddb_name" {
  description = "The name of the Dynamo DB"
  type        = string
}

variable "read_capacity" {
  type        = number
}

variable "write_capacity" {
  type        = number
}

variable "hash_key" {
  type        = string
}

variable "attribute_name" {
  type        = string
}

variable "attribute_type" {
  type        = string
}


variable "tags" {
  description = "A map of tags to assign to the bucket"
  type        = map(string)
}
