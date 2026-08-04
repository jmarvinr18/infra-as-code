output "state_bucket" {
  value = module.s3_bucket.bucket_id
}

output "lock_table" {
  value = module.dynamodb_table
}