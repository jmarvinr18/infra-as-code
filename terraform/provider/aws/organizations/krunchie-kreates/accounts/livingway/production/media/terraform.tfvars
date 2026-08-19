client            = "livingway"
client_account_id = "792682046440"
environment       = "production"
region            = "ap-southeast-1"

bucket_name = "livingway-media-production"

# The CloudFront policy grants a service principal, not the public, so these
# all stay on.
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

# ACLs disabled. The API must not send "public-read" on upload.
object_ownership = "BucketOwnerEnforced"

allowed_origins = [
  "https://livingwayapostolics.org",
  "https://www.livingwayapostolics.org",
  "https://event.livingwayapostolics.org",
  "https://admin.livingwayapostolics.org",
]

cors_rules = [
  {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = [
      "https://livingwayapostolics.org",
      "https://www.livingwayapostolics.org",
      "https://event.livingwayapostolics.org",
      "https://admin.livingwayapostolics.org",
    ]
    expose_headers  = ["ETag", "Content-Length", "Content-Type"]
    max_age_seconds = 3600
  }
]

lifecycle_rules = [
  {
    id              = "expire-noncurrent-versions"
    status          = "Enabled"
    noncurrent_days = 30
  },
  {
    id                              = "abort-incomplete-uploads"
    status                          = "Enabled"
    abort_incomplete_multipart_days = 7
  }
]

# Optional custom CDN domain. The certificate MUST be issued in us-east-1.
# aliases             = ["media.livingwayapostolics.org"]
# acm_certificate_arn = "arn:aws:acm:us-east-1:111122223333:certificate/..."

# Read the README before enabling. This breaks social link previews and the
# QR code inside ticket emails.
enable_hotlink_protection = false
allowed_referer_domains   = ["livingwayapostolics.org"]

# Upload-only IAM user for the API backend. Set false if the API ever moves to
# ECS/EC2, and attach app_policy_arn to that workload's role instead.
create_app_iam_user = true
app_iam_user_name   = "livingway-api-backend"

tags = {
  "Name"       = "livingway-media"
  "Client"     = "livingway"
  "Created-by" = "terraform-jmr"
}
