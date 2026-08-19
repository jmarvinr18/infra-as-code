variable "bucket_name" {
  description = "The name of the GCS bucket"
  type        = string
}

variable "project" {
  type = string
}

variable "location" {
  type = string
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "uniform_bucket_level_access" {
  type    = bool
  default = true
}

variable "public_access_prevention" {
  type    = string
  default = "enforced"
}

variable "versioning" {
  type    = bool
  default = true
}

variable "labels" {
  description = "A map of labels to assign to the bucket"
  type        = map(string)
  default     = {}
}
