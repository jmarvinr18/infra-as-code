bucket_name = "jmr-jenkins-backup-bucket"

bucket_policy_name = "JenkinsS3BackupUploadPolicy"
role_name = "JenkinsS3BackupRole"
tags = {
  "Name"        = "global-devsecops-jenkins"
  "Environment" = "production"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}