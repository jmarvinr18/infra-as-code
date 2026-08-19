variable "project_ids" {
  description = "Map of project ids to enable the apis on, keyed by env."
  type        = map(string)
}

variable "services" {
  description = "Apis to enable on every project"
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "billingbudgets.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}

variable "disable_on_destroy" {
  type    = bool
  default = false
}

variable "disable_dependent_services" {
  type    = bool
  default = false
}
