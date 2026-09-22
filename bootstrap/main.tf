# One-time bootstrap of remote Terraform state (S3).
# Locking uses native S3 lockfiles (Terraform >= 1.10) — no DynamoDB table.
# Uses local state intentionally — apply once, then point live/* at the outputs.

data "aws_caller_identity" "current" {}

resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  bucket_name = "${var.state_bucket_prefix}-${data.aws_caller_identity.current.account_id}-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = local.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
