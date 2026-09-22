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

output "backend_hcl_example" {
  description = "Paste into live/ops/backend.hcl after bootstrap."
  value       = <<-EOT
    bucket       = "${aws_s3_bucket.tfstate.id}"
    key          = "live/ops/terraform.tfstate"
    region       = "${var.aws_region}"
    encrypt      = true
    use_lockfile = true
  EOT
}
