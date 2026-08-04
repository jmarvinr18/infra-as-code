variable "bucket_id" {
  description = "The ID of the S3 bucket"
  type        = string
}

variable "rules" {
  type = list(object({
    id                              = string
    status                          = string
    prefix                          = optional(string, "")
    noncurrent_days                 = optional(number)
    abort_incomplete_multipart_days = optional(number)
  }))
}
