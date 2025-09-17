

module "ebs_csi_driver_role" {
  source  = "../../../../modules/iam/role"
  role_name = var.ebs_csi_driver_role_name
  assume_role_policy = var.eks_pods_service_file_name
  tags = var.tags
  
}

module "ebs_csi_driver_role_policy_attachment" {
  source = "../../../../modules/iam/role_policy_attachment"
  role = module.ebs_csi_driver_role.name
  policy_attachments = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}

module "ebs_csi_driver_encryption_policy" {
  source = "../../../../modules/iam/policy"

  name = "${var.eks_cluster_name}-ebs-csi-driver-encryption"

  policy_file_name = var.ebs_csi_driver_encryption_policy
}

module "ebs_csi_driver_encryption_attachment" {
  source = "../../../../modules/iam/role_policy_attachment"
  role = module.ebs_csi_driver_role.name
  policy_attachments =  [ module.ebs_csi_driver_encryption_policy.arn ]
}

module "ebs_csi_driver_pod_association" {
  source = "../../../../modules/eks/pod-identity-association"
  namespace = "kube-system"
  cluster_name = var.eks_cluster_name
  service_account = "ebs-csi-controller"
  role_arn = module.ebs_csi_driver_role.arn
}

module "ebs_csi_driver" {
  source = "../../../../modules/eks/add-on"
  add_ons = var.ebs_csi_add_ons
  eks_cluster_name = var.eks_cluster_name
}



