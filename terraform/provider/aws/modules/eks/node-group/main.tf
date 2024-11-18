resource "aws_iam_role" "eks_cluster_nodes_role" {
  name = "${var.cluster_name}-node-group-${var.node_group_name}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "ec2_create_tags_policy" {
  name        = "${var.cluster_name}-${var.node_group_name}-EC2CreateTagsPolicy"
  description = "Policy to allow EC2 instances to create tags"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ec2:CreateTags",
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node-AmazonEC2FullAccessPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.eks_cluster_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node-AWSWAFReadOnlyAccessPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSWAFReadOnlyAccess"
  role       = aws_iam_role.eks_cluster_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_cluster_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "attach_create_tags_policy" {
  policy_arn = aws_iam_policy.ec2_create_tags_policy.arn
  role       = aws_iam_role.eks_cluster_nodes_role.name
}


resource "aws_eks_node_group" "priv-nodes" {
  cluster_name = var.cluster_name
  version      = var.eks_cluster_version

  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_cluster_nodes_role.arn
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  subnet_ids = var.target_subnets

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  scaling_config {
    max_size     = 20
    min_size     = 1
    desired_size = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # taint {
  #   key = "team"
  #   value = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  launch_template {
    name    = aws_launch_template.eks-node-template.name
    version = aws_launch_template.eks-node-template.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_cluster_node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_cluster_node-AmazonEC2ContainerRegistryReadOnly
  ]

  # Allow external changes 
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name = "aws_eks_node_group"
  }
}

resource "random_id" "index" {
  byte_length = 2
}

resource "aws_launch_template" "eks-node-template" {
  name = "eks-node-${var.node_group_name}-template"

  key_name = var.ssh_key

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.volume_size
      volume_type = "gp2"
    }
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}