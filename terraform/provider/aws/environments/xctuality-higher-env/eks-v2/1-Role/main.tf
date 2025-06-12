

##### EKS CLUSTER ROLE & POLICIES

module "eks_cluster_role" {
  source = "../../../../modules/iam/role"

  role_name = var.eks_cluster_role_name

  assume_role_policy = var.eks_assume_role_policy

  tags = var.tags

}

module "eks_policy_attachment" {
  source = "../../../../modules/iam/role_policy_attachment"

  policy_attachments = var.eks_cluster_policy_attachments

  role = module.eks_cluster_role.name
}


##### EKS NODES ROLE & POLICIES

module "eks_nodes_role" {
  source = "../../../../modules/iam/role"

  role_name = var.eks_node_role_name

  assume_role_policy = var.eks_nodes_assume_role_policy

  tags = var.tags
}


module "eks_node_policy_attachment" {
  source             = "../../../../modules/iam/role_policy_attachment"
  policy_attachments = var.eks_node_policy_attachments

  role = module.eks_nodes_role.name

}


##### EKS LOAD BALANCER CONTROLLER ROLE & POLICIES

# module "eks_lbc_role" {
#   source = "../../../../modules/iam/role"

#   role_name = var.eks_lbc_role_name

#   assume_role_policy = var.eks_pods_service_file_name

#   tags = var.tags
# }

# module "aws_lbc_policy" {
#   source           = "../../../../modules/iam/policy"
#   name             = var.aws_lbc_policy_name
#   policy_file_name = var.lbc_policy_file_name
# }


# module "aws_lbc_policy_attachment" {
#   source             = "../../../../modules/iam/role_policy_attachment"
#   policy_attachments = [module.aws_lbc_policy.arn]

#   role = module.eks_lbc_role.name

# }






##### EKS ROLE BASED ACCESS CONTROL

# Admin
module "eks_admin_role" {
  source = "../../../../modules/iam/role"
  role_name = "${var.env}-${var.eks_cluster_name}-admin"
  assume_role_policy_type = "string"
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
            }
        }
    ]
  }
  POLICY

  tags = var.tags
}

module "eks_admin_policy" {
  source = "../../../../modules/iam/policy"
  name = var.eks_admin_policy_name
  policy_file_name = var.eks_admin_policy_file_name
}

module "eks_admin_user" {
  source = "../../../../modules/iam/user"
  iam_user_name = var.eks_admin_user_name

}

module "eks_admin_role_policy_attachment" {
    source             = "../../../../modules/iam/role_policy_attachment"
    role = module.eks_admin_role.name    
    policy_attachments = [module.eks_admin_policy.arn]
}


module "eks_assume_admin_policy" {
  source = "../../../../modules/iam/policy"
  name = var.eks_assume_admin_policy_name
  policy_type = "string"
  policy_file_name = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "${module.eks_admin_role.arn}"
        }
    ]  
  }
  POLICY
}

module "eks_admin_user_policy_attachment" {
    source             = "../../../../modules/iam/user_policy_attachment"
    user = module.eks_admin_user.name    
    policy_attachments = [module.eks_admin_policy.arn]
}


# Developer

module "eks_developer_policy" {
  source = "../../../../modules/iam/policy"
  name = var.eks_developer_policy_name
  policy_file_name = var.eks_developer_policy_file_name
}

module "eks_developer_user" {
  source = "../../../../modules/iam/user"
  iam_user_name = var.eks_developer_user_name
}

module "eks_developer_user_policy_attachment" {
    source             = "../../../../modules/iam/user_policy_attachment"
    user = module.eks_developer_user.name    
    policy_attachments = [module.eks_developer_policy.arn]
}