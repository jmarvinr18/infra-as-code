variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the bucket"
  type        = map(string)
}

# variable "prevent_destroy" {
#   type = bool
# }

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

variable "sse_algorithm" {
  type = string
  default = "AES256"
}