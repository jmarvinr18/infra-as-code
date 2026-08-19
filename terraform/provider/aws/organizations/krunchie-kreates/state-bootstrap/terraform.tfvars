
bucket_name = "krunchie-tfstate"
read_capacity = 1
write_capacity = 1

ddb_name = "terraform-locks"
hash_key = "LockID"
attribute_name = "LockID"
attribute_type = "S"
block_public_acls = true
block_public_policy = true
ignore_public_acls = true
restrict_public_buckets =  true

tags = {
  "Name"        = "krunchie-kreates"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}

