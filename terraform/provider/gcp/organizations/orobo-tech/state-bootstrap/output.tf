output "state_bucket" {
  value = module.gcs_bucket.name
}

output "state_bucket_url" {
  value = module.gcs_bucket.url
}
