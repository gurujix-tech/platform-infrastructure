output "aws_account_id" {
  description = "Account where state resources were created."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = var.aws_region
}

output "state_bucket_name" {
  description = "S3 bucket for Terraform remote state — put this in live/ops/backend.hcl."
  value       = aws_s3_bucket.tfstate.id
}

output "lock_table_name" {
  description = "DynamoDB table for state locking — put this in live/ops/backend.hcl."
  value       = aws_dynamodb_table.locks.name
}

output "backend_hcl_example" {
  description = "Paste into live/ops/backend.hcl after bootstrap."
  value       = <<-EOT
    bucket         = "${aws_s3_bucket.tfstate.id}"
    key            = "live/ops/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${aws_dynamodb_table.locks.name}"
    encrypt        = true
  EOT
}
