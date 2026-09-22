locals {
  cluster_name = "gurujix-platform"
}

data "aws_iam_policy_document" "eks_cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  count = var.enable_eks ? 1 : 0

  name               = "${local.cluster_name}-cluster"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json

  tags = {
    Name      = "${local.cluster_name}-cluster"
    Component = "compute"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count = var.enable_eks ? 1 : 0

  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node" {
  count = var.enable_eks ? 1 : 0

  name               = "${local.cluster_name}-node"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume.json

  tags = {
    Name      = "${local.cluster_name}-node"
    Component = "compute"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  count = var.enable_eks ? 1 : 0

  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  count = var.enable_eks ? 1 : 0

  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr" {
  count = var.enable_eks ? 1 : 0

  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "platform" {
  count = var.enable_eks ? 1 : 0

  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster[0].arn
  version  = var.eks_version

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = []

  tags = {
    Name      = local.cluster_name
    Component = "compute"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

resource "aws_eks_node_group" "platform" {
  count = var.enable_eks ? 1 : 0

  cluster_name    = aws_eks_cluster.platform[0].name
  node_group_name = "platform"
  node_role_arn   = aws_iam_role.eks_node[0].arn
  subnet_ids      = aws_subnet.public[*].id
  version         = var.eks_version

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  instance_types = var.eks_node_instance_types

  scaling_config {
    desired_size = var.eks_node_desired_size
    min_size     = var.eks_node_desired_size
    max_size     = max(var.eks_node_desired_size + 1, 2)
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name      = "${local.cluster_name}-nodes"
    Component = "compute"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker,
    aws_iam_role_policy_attachment.eks_node_cni,
    aws_iam_role_policy_attachment.eks_node_ecr,
  ]
}
