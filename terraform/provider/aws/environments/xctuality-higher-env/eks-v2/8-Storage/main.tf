

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


module "efs_csi_driver" {
  source = "../../../../modules/efs/file-system"

  creation_token = "${var.eks_cluster_name}-efs-csi"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  tags = var.tags
}

module "efs_csi_mount_target_1" {
  source = "../../../../modules/efs/mount-target"
  file_system_id = module.efs_csi_driver.id
  subnet_id = data.aws_subnet.private_zone_1.id
  security_groups = [data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id]
  
}

module "efs_csi_mount_target_2" {
  source = "../../../../modules/efs/mount-target"
  file_system_id = module.efs_csi_driver.id
  subnet_id = data.aws_subnet.private_zone_2.id
  security_groups = [data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id]
}

module "efs_csi_driver_role" {
  source  = "../../../../modules/iam/role"
  role_name = "${var.eks_cluster_name}-efs-csi-role"
  assume_role_policy_type = "string"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver.json
  tags = var.tags
  
}

module "aws_efs_csi_driver_policy_attachment" {
  source = "../../../../modules/iam/role_policy_attachment"
  role = module.efs_csi_driver_role.name
  policy_attachments = ["arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"]
  
}


module "helm_efs_csi" {
  source = "../../../../modules/helm"
  helm_releases = [
    {
      helm_release_name = "aws-efs-csi-driver"
      helm_repository   = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
      chart             = "aws-efs-csi-driver"
      create_namespace = false
      namespace         = "kube-system"
      helm_version      = "3.0.3"
      helm_values = [""]
      set = [
        {
          name  = "controller.serviceAccount.name"
          value = "efs-csi-controller-sa"
        },
        {
          name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
          value = module.efs_csi_driver_role.arn
        }        
      ]
    }
  ]
  depends_on = [
    module.efs_csi_driver, 
    module.efs_csi_mount_target_1, 
    module.efs_csi_mount_target_2, 
    module.efs_csi_driver_role, 
    module.aws_efs_csi_driver_policy_attachment]
}