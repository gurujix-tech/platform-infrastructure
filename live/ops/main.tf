# Phase 8a smoke stack: proves remote state works without creating billable network/compute.
# Next slices add VPC / EKS modules here (or as sibling live/* stacks).

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
