resource "google_storage_bucket" "this" {
  name     = var.bucket_name
  project  = var.project
  location = var.location

  # Guardrail: don't let a stray `terraform destroy` delete your state history.
  force_destroy = var.force_destroy

  lifecycle {
    prevent_destroy = true
  }

  # State can contain secrets, so no per-object acls.
  uniform_bucket_level_access = var.uniform_bucket_level_access
  public_access_prevention    = var.public_access_prevention

  # Keep every version of the state file so you can recover from corruption.
  versioning {
    enabled = var.versioning
  }

  labels = var.labels
}
