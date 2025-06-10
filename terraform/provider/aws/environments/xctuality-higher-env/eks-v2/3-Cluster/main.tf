module "eks_cluster" {
  source = "../../../../modules/eks/cluster"

  eks_cluster_name = var.eks_cluster_name
  eks_version = var.eks_version
  role_arn = data.aws_iam_role.cluster_role.arn

  vpc_config = {
    endpoint_private_access =  var.vpc_config.endpoint_private_access
    endpoint_public_access = var.vpc_config.endpoint_public_access
    subnet_ids = [
      data.aws_subnet.private_zone_1.id,
      data.aws_subnet.private_zone_2.id
    ]
  }

  access_config = {
    authentication_mode = var.access_config.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.access_config.bootstrap_cluster_creator_admin_permissions
  }

  tags = var.tags

}



module "oidc" {
  source = "../../../../modules/iam/openid_connect_provider"
  url = module.eks_cluster.oidc_issuer
  client_id_list = [ "sts.amazonaws.com" ]
  tags = var.tags
  
}

##### EKS LOAD BALANCER CONTROLLER ROLE & POLICIES

module "eks_lbc_role" {
  source = "../../../../modules/iam/role"

  role_name = var.eks_lbc_role_name
  assume_role_policy_type = "string"
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${module.oidc.arn}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${module.oidc.url}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller",
              "${module.oidc.url}:aud": "sts.amazonaws.com"
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "pods.eks.amazonaws.com"
        },
        "Action": [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  }
  POLICY


  tags = var.tags
}


module "aws_lbc_policy" {
  source           = "../../../../modules/iam/policy"
  name             = var.aws_lbc_policy_name
  policy_file_name = var.lbc_policy_file_name
}


module "aws_lbc_policy_attachment" {
  source             = "../../../../modules/iam/role_policy_attachment"
  policy_attachments = [module.aws_lbc_policy.arn]

  role = module.eks_lbc_role.name

}