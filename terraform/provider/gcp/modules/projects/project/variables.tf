variable "projects" {
  description = "Map of projects to create, keyed by env."
  type = map(object({
    project_id   = string
    project_name = string
    labels       = map(string)
  }))
}

variable "org_id" {
  type = string
}

variable "folder_id" {
  description = "Folder to create the projects under, takes precedence over org_id"
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "Billing account id to link. Empty leaves the projects unlinked."
  type        = string
  default     = ""
}

variable "auto_create_network" {
  description = "Create the legacy default VPC network on project creation"
  type        = bool
  default     = false
}

variable "deletion_policy" {
  description = "PREVENT, ABANDON or DELETE"
  type        = string
  default     = "PREVENT"
}
