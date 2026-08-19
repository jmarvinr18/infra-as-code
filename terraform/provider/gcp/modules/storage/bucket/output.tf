output "name" {
  description = "The name of the GCS bucket"
  value       = google_storage_bucket.this.name
}

output "bucket_id" {
  value = google_storage_bucket.this.id
}

output "url" {
  value = google_storage_bucket.this.url
}
