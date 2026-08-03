locals {
  origin_id = "${var.bucket_name}-origin"

  media_base_url = length(var.aliases) > 0 ? "https://${var.aliases[0]}" : "https://${module.cloudfront_distribution.domain_name}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Bucket — stays private. CloudFront is the only public surface.
# ─────────────────────────────────────────────────────────────────────────────

module "media_bucket" {
  source = "../../../../../../modules/s3/bucket"

  bucket_name = var.bucket_name
  tags        = var.tags

  # The CloudFront policy below grants a service principal, not the public, so
  # every block-public setting stays on.
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

module "media_bucket_ownership" {
  source = "../../../../../../modules/s3/bucket_ownership"

  bucket_id        = module.media_bucket.bucket_id
  object_ownership = var.object_ownership
}

module "media_bucket_cors" {
  source = "../../../../../../modules/s3/bucket_cors"

  bucket_id  = module.media_bucket.bucket_id
  cors_rules = var.cors_rules
}

module "media_bucket_lifecycle" {
  source = "../../../../../../modules/s3/bucket_lifecycle"

  bucket_id = module.media_bucket.bucket_id
  rules     = var.lifecycle_rules
}

module "media_bucket_policy" {
  source = "../../../../../../modules/s3/bucket_policy"

  bucket_id = module.media_bucket.bucket_id
  policy    = data.aws_iam_policy_document.media_bucket.json
}

data "aws_iam_policy_document" "media_bucket" {
  statement {
    sid       = "AllowCloudFrontRead"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    # Scopes the grant to this one distribution.
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront_distribution.arn]
    }
  }

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# CDN
# ─────────────────────────────────────────────────────────────────────────────

module "cloudfront_oac" {
  source = "../../../../../../modules/cloudfront/origin_access_control"

  name        = "${var.bucket_name}-oac"
  description = "Lets only this distribution read the media bucket"
}

module "cloudfront_cache_policy" {
  source = "../../../../../../modules/cloudfront/cache_policy"

  name        = "${var.bucket_name}-media-cache"
  comment     = "Long-lived cache for event and attendee media"
  default_ttl = var.cache_default_ttl
  max_ttl     = var.cache_max_ttl
  min_ttl     = var.cache_min_ttl
  headers     = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
}

module "cloudfront_response_headers_policy" {
  source = "../../../../../../modules/cloudfront/response_headers_policy"

  name            = "${var.bucket_name}-media-headers"
  comment         = "CORS allowlist plus baseline security headers"
  allowed_origins = var.allowed_origins
}

# Hotlink deterrence, off unless enable_hotlink_protection is true.
#
# Requests with no Referer are allowed through on purpose: social scrapers and
# email image proxies send none, and blocking them would break event link
# previews and the QR code on ticket emails. That also means this cannot stop a
# direct fetch — it only discourages other sites from embedding the images.
module "cloudfront_referer_function" {
  source = "../../../../../../modules/cloudfront/function"
  count  = var.enable_hotlink_protection ? 1 : 0

  name    = "${var.bucket_name}-referer-check"
  comment = "Rejects embeds from sites outside allowed_referer_domains"

  code = templatefile("${path.module}/functions/referer_check.js.tftpl", {
    allowed_domains = jsonencode(var.allowed_referer_domains)
  })
}

module "cloudfront_distribution" {
  source = "../../../../../../modules/cloudfront/distribution"

  comment     = "Living Way Apostolics media (${var.environment})"
  price_class = var.price_class
  aliases     = var.aliases

  origin_domain_name       = "${var.bucket_name}.s3.${var.region}.amazonaws.com"
  origin_id                = local.origin_id
  origin_access_control_id = module.cloudfront_oac.id

  cache_policy_id            = module.cloudfront_cache_policy.id
  response_headers_policy_id = module.cloudfront_response_headers_policy.id

  function_associations = var.enable_hotlink_protection ? [{
    event_type   = "viewer-request"
    function_arn = module.cloudfront_referer_function[0].arn
  }] : []

  acm_certificate_arn = var.acm_certificate_arn
  tags                = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Application access
# ─────────────────────────────────────────────────────────────────────────────

# Upload only. The API's entire S3 surface is Storage::put/putFileAs — it never
# reads, lists or deletes, and Storage::url() is string concatenation against
# AWS_URL rather than an API call. So PutObject is the whole requirement.
#
# Deliberately NOT granted:
#   s3:GetObject    — reads are served by CloudFront, not the application
#   s3:DeleteObject — replacing an image is an overwrite (a Put); old versions
#                     are cleaned up by the bucket lifecycle rule instead
#   s3:ListBucket   — nothing enumerates the bucket
#   s3:PutObjectAcl — ACLs are disabled on the bucket (BucketOwnerEnforced)
#
# A leaked key can therefore add or overwrite objects, but cannot read the
# bucket's contents, enumerate it, or destroy anything permanently.
data "aws_iam_policy_document" "app_upload" {
  statement {
    sid       = "UploadMediaObjects"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }

  # Only reachable if an upload ever exceeds the SDK's multipart threshold.
  # Grants nothing beyond discarding a part-finished upload of its own.
  statement {
    sid       = "CleanUpFailedMultipartUploads"
    effect    = "Allow"
    actions   = ["s3:AbortMultipartUpload"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }
}

module "app_policy" {
  source = "../../../../../../modules/iam/policy"

  name             = "${var.bucket_name}-app-upload"
  policy_type      = "string"
  policy_file_name = data.aws_iam_policy_document.app_upload.json
}

# The API runs outside AWS, so it has no role to assume and needs a key.
# Where the workload does have a role, attach app_policy_arn to that instead.
module "app_user" {
  source = "../../../../../../modules/iam/user"
  count  = var.create_app_iam_user ? 1 : 0

  iam_user_name = var.app_iam_user_name
  tags          = var.tags
}

module "app_user_policy_attachment" {
  source = "../../../../../../modules/iam/user_policy_attachment"
  count  = var.create_app_iam_user ? 1 : 0

  user               = module.app_user[0].name
  policy_attachments = [module.app_policy.arn]
}

module "app_access_key" {
  source = "../../../../../../modules/iam/access_key"
  count  = var.create_app_iam_user ? 1 : 0

  iam_user_name = module.app_user[0].name
}
