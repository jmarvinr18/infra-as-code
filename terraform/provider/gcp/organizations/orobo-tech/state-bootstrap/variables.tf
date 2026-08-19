
variable "bucket_name" {
  description = "The name of the GCS bucket holding terraform state"
  type        = string
}

variable "project" {
  description = "Project that owns the state bucket"
  type        = string
}

variable "location" {
  type = string
}

variable "region" {
  type = string
}

variable "uniform_bucket_level_access" {
  type = bool
}

variable "public_access_prevention" {
  type = string
}

variable "versioning" {
  type = bool
}

variable "labels" {
  description = "A map of labels to assign to the bucket"
  type        = map(string)
}
