variable "aws_region" {
  description = "AWS region for the platform stack."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the platform VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "az_count" {
  description = "How many AZs to use (public + private subnet each). Keep at 2 for learning."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "enable_nat_gateway" {
  description = <<-EOT
    Create a single NAT Gateway for private-subnet egress.
    Default false to avoid ~$30+/mo while learning. Set true before private
    workloads need outbound internet (EKS pulls, apt, etc.).
  EOT
  type        = bool
  default     = false
}

variable "enable_eks" {
  description = "Create the learning EKS cluster + node group. Set false to tear down compute while keeping the VPC."
  type        = bool
  default     = true
}

variable "eks_version" {
  description = "Kubernetes version for the EKS control plane and node group."
  type        = string
  default     = "1.36"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired node count (min matches this; max is desired+1)."
  type        = number
  default     = 1

  validation {
    condition     = var.eks_node_desired_size >= 1 && var.eks_node_desired_size <= 3
    error_message = "eks_node_desired_size must be between 1 and 3 for the learning footprint."
  }
}

variable "ecr_repositories" {
  description = "ECR repository names (match service CI ECR_REPOSITORY)."
  type        = list(string)
  default     = ["service-orders"]
}

variable "create_github_oidc_provider" {
  description = "true = create the account GitHub OIDC provider; false = use the existing one (default for this account)."
  type        = bool
  default     = false
}

variable "github_oidc_subjects" {
  description = "Allowed GitHub Actions token.sub values (must match the real JWT sub for this org)."
  type        = list(string)
  default = [
    "repo:gurujix-tech@299745487/service-orders@1358132490:ref:refs/heads/main",
  ]
}
