output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = data.aws_region.current.name
}

output "remote_state_ok" {
  description = "Always true after a successful apply against the S3 backend."
  value       = true
}
