output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = data.aws_region.current.name
}

output "vpc_id" {
  value = aws_vpc.platform.id
}

output "vpc_cidr" {
  value = aws_vpc.platform.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "nat_gateway_enabled" {
  value = var.enable_nat_gateway
}

output "eks_cluster_name" {
  value = var.enable_eks ? aws_eks_cluster.platform[0].name : null
}

output "eks_cluster_endpoint" {
  value = var.enable_eks ? aws_eks_cluster.platform[0].endpoint : null
}

output "eks_configure_kubectl" {
  description = "Run locally after apply to talk to the cluster."
  value = var.enable_eks ? format(
    "aws eks update-kubeconfig --region %s --name %s",
    data.aws_region.current.name,
    aws_eks_cluster.platform[0].name,
  ) : null
}

output "ecr_repository_urls" {
  value = { for name, repo in aws_ecr_repository.services : name => repo.repository_url }
}

output "github_actions_role_arn" {
  description = "Set as GitHub repo secret AWS_ROLE_ARN on service-orders."
  value       = aws_iam_role.github_actions_ecr.arn
}
