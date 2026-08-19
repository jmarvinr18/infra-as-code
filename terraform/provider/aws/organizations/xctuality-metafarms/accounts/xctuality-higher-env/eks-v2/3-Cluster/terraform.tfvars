region     = "ap-southeast-1"

eks_cluster_role_name = "eks-cluster-role"

vpc_config = {
  endpoint_private_access =  false
  endpoint_public_access = true
}

  access_config = {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }


tags = {
  "Name"        = "xctuality-higher-env-eks"
  "Environment" = "staging"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}
