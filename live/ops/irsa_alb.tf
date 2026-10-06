# IRSA for AWS Load Balancer Controller (when EKS is enabled).

data "tls_certificate" "eks" {
  count = var.enable_eks ? 1 : 0
  url   = "${aws_eks_cluster.platform[0].identity[0].oidc[0].issuer}/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "eks" {
  count = var.enable_eks ? 1 : 0

  url             = aws_eks_cluster.platform[0].identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks[0].certificates[0].sha1_fingerprint]

  tags = {
    Name      = "${local.cluster_name}-eks-oidc"
    Component = "identity"
  }
}

data "aws_iam_policy_document" "alb_controller_assume" {
  count = var.enable_eks ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.platform[0].identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.platform[0].identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_policy" "alb_controller" {
  count = var.enable_eks ? 1 : 0

  name   = "${local.cluster_name}-aws-lbc"
  policy = file("${path.module}/policies/aws-lbc-iam-policy.json")

  tags = {
    Name      = "${local.cluster_name}-aws-lbc"
    Component = "identity"
  }
}

resource "aws_iam_role" "alb_controller" {
  count = var.enable_eks ? 1 : 0

  name               = "${local.cluster_name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume[0].json

  tags = {
    Name      = "${local.cluster_name}-aws-lbc"
    Component = "identity"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  count = var.enable_eks ? 1 : 0

  role       = aws_iam_role.alb_controller[0].name
  policy_arn = aws_iam_policy.alb_controller[0].arn
}
