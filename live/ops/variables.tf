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
