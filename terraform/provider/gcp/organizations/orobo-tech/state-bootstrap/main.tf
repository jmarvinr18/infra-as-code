

module "gcs_bucket" {
  source = "../../../modules/storage/bucket"

  bucket_name = var.bucket_name
  project     = var.project
  location    = var.location

  uniform_bucket_level_access = var.uniform_bucket_level_access
  public_access_prevention    = var.public_access_prevention
  versioning                  = var.versioning

  labels = var.labels
}
