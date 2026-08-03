output "bucket_name" {
  value = module.media_bucket.name
}

output "cloudfront_domain_name" {
  value = module.cloudfront_distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "Needed to invalidate the cache after replacing an image at an existing key"
  value       = module.cloudfront_distribution.id
}

output "media_base_url" {
  description = "Set as AWS_URL in the API .env"
  value       = local.media_base_url
}

output "app_policy_arn" {
  description = "Upload-only S3 policy. Attach to an ECS task role or EC2 instance profile where one exists."
  value       = module.app_policy.arn
}

output "app_iam_user_name" {
  value = var.create_app_iam_user ? module.app_user[0].name : null
}

output "app_access_key_id" {
  description = "Set as AWS_ACCESS_KEY_ID in the API .env"
  value       = var.create_app_iam_user ? module.app_access_key[0].id : null
}

# Held in state, so the state bucket must stay locked down. Rotate by tainting
# module.app_access_key and re-applying.
output "app_secret_access_key" {
  description = "Set as AWS_SECRET_ACCESS_KEY. Read with: terraform output -raw app_secret_access_key"
  value       = var.create_app_iam_user ? module.app_access_key[0].secret : null
  sensitive   = true
}

output "env_block" {
  description = "Paste into the API .env once applied (credentials excluded)"
  value       = <<-EOT
    AWS_DEFAULT_REGION=${var.region}
    AWS_BUCKET=${var.bucket_name}
    AWS_URL=${local.media_base_url}
    AWS_USE_PATH_STYLE_ENDPOINT=false
    MEDIA_DISK=s3
    QR_DISK=s3
  EOT
}
