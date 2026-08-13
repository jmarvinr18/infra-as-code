module "role" {
  source = "../../../../../../modules/glue/role"

  role_name = var.role_name

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
  ]

  inline_policies = [
    {
      name = "s3-processed-read"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "S3BucketList"
            Effect = "Allow"
            Action = ["s3:ListBucket"]
            Resource = "arn:aws:s3:::${var.s3_bucket}"
          },
          {
            Sid    = "S3ObjectRead"
            Effect = "Allow"
            Action = ["s3:GetObject"]
            Resource = "arn:aws:s3:::${var.s3_bucket}/${var.s3_prefix}*"
          }
        ]
      })
    }
  ]

  tags = var.tags
}

module "database" {
  source = "../../../../../../modules/glue/catalog_database"

  name        = var.database_name
  description = var.database_description
}

module "table" {
  source = "../../../../../../modules/glue/catalog_table"

  name          = var.table_name
  database_name = module.database.name
  s3_location   = "s3://${var.s3_bucket}/${var.s3_prefix}"

  columns = var.table_columns

  depends_on = [module.database]
}

module "ruleset" {
  source = "../../../../../../modules/glue/data_quality_ruleset"

  name          = var.ruleset_name
  ruleset       = var.ruleset
  database_name = module.database.name
  table_name    = module.table.name

  depends_on = [module.table]
}
