variable "bucket_id" {
  description = "The ID of the S3 bucket"
  type        = string
}

variable "object_ownership" {
  description = "BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter"
  type        = string
  default     = "BucketOwnerEnforced"
}
