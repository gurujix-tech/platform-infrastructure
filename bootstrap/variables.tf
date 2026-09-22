variable "aws_region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_prefix" {
  description = "Prefix for the S3 state bucket name (a random suffix is appended for global uniqueness)."
  type        = string
  default     = "gurujix-tfstate"
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
  default     = "gurujix-terraform-locks"
}
