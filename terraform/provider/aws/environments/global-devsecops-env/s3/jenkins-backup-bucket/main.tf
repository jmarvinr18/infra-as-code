module "s3_bucket" {
  source      = "../../../../modules/s3/bucket"
  bucket_name = var.bucket_name
  tags        = var.tags
}


module "s3_backup_role" {
  source = "../../../../modules/iam/role"

  role_name = var.role_name
  assume_role_policy_type = "string"
  assume_role_policy = <<POLICY
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "Service": "ec2.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
          }
      ]
  }
  POLICY

  tags = var.tags

}

# module "policy" {
#   source           = "../../../../modules/iam/policy"
#   name             = var.bucket_policy_name
#   policy_type      = "string"
#   policy_file_name = <<POLICY
#   {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Sid": "AllowOnlyBackupEC2RoleToUpload",
#           "Effect": "Allow",
#           "Principal": {
#             "AWS": "${module.s3_backup_role.arn}"
#           },
#           "Action": "s3:PutObject",
#           "Resource": "arn:aws:s3:::${var.bucket_name}/*"
#         }
#       ]
#   }
#   POLICY
# }

module "jenkins_backup_bucket_policy" {
  source      = "../../../../modules/s3/bucket_policy"
  bucket_id   = module.s3_bucket.bucket_id
  policy      = <<POLICY
  {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowOnlyBackupEC2RoleToUpload",
          "Effect": "Allow",
          "Principal": {
            "AWS": "${module.s3_backup_role.arn}"
          },
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::${var.bucket_name}/*"
        }
      ]
  }
  POLICY

}