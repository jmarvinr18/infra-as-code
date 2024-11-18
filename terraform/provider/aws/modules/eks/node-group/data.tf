data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${var.eks_cluster_version}/amazon-linux-2/recommended/release_version"
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/workers.tpl")

  vars = {
    cluster_name  = var.cluster_name
    random_suffix = random_id.index.hex
    sysctl        = var.sysctl
  }
}

data "aws_eks_cluster" "current" {
  name = var.cluster_name
}
