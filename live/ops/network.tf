data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "gurujix-platform"
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  public_subnet_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 10)]
}

resource "aws_vpc" "platform" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = local.name
    Component = "network"
  }
}

resource "aws_internet_gateway" "platform" {
  vpc_id = aws_vpc.platform.id

  tags = {
    Name      = local.name
    Component = "network"
  }
}

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.platform.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${local.name}-public-${local.azs[count.index]}"
    Component                = "network"
    Tier                     = "public"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  count = var.az_count

  vpc_id            = aws_vpc.platform.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name                              = "${local.name}-private-${local.azs[count.index]}"
    Component                         = "network"
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.platform.id

  tags = {
    Name      = "${local.name}-public"
    Component = "network"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.platform.id
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name      = "${local.name}-nat"
    Component = "network"
  }

  depends_on = [aws_internet_gateway.platform]
}

resource "aws_nat_gateway" "platform" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name      = local.name
    Component = "network"
  }

  depends_on = [aws_internet_gateway.platform]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.platform.id

  tags = {
    Name      = "${local.name}-private"
    Component = "network"
  }
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.platform[0].id
}

resource "aws_route_table_association" "private" {
  count = var.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

moved {
  from = aws_vpc.ops
  to   = aws_vpc.platform
}

moved {
  from = aws_internet_gateway.ops
  to   = aws_internet_gateway.platform
}

moved {
  from = aws_nat_gateway.ops
  to   = aws_nat_gateway.platform
}
