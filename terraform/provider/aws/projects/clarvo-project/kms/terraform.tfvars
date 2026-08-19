
region = "ap-southeast-1"
env = "develop"

tags = {
  "project"     = "aip-c01"
}


deletion_window_in_days = 7
description = "Clarvo data/training bucket encryption (AIP-C01)"
enable_key_rotation = true
kms_alias_name = "alias/clarvo-data"
