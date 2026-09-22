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
