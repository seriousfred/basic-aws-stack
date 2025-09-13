
data "aws_vpc" "existing_vpc" {
  count = var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

resource "aws_vpc" "new_vpc" {
  count                = var.vpc_id == "" ? 1 : 0
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# get available azs
data "aws_availability_zones" "az_availables" {
  state = "available"
}

# subnets
resource "aws_subnet" "public_subnets" {
  count                   = var.vpc_id == "" ? var.num_subnets : 0
  availability_zone       = data.aws_availability_zones.az_availables.names[count.index]
  vpc_id                  = aws_vpc.new_vpc[0].id
  cidr_block              = cidrsubnet(aws_vpc.new_vpc[0].cidr_block, 7, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.vpc_id == "" ? var.num_subnets : 0
  availability_zone = data.aws_availability_zones.az_availables.names[count.index]
  vpc_id            = aws_vpc.new_vpc[0].id
  cidr_block        = cidrsubnet(aws_vpc.new_vpc[0].cidr_block, 7, count.index + var.num_subnets)
  tags = {
    Name = "${var.prefix}-private-${count.index}"
  }
}

resource "aws_subnet" "data_subnets" {
  count             = var.vpc_id == "" ? var.num_subnets : 0
  availability_zone = data.aws_availability_zones.az_availables.names[count.index]
  vpc_id            = aws_vpc.new_vpc[0].id
  cidr_block        = cidrsubnet(aws_vpc.new_vpc[0].cidr_block, 7, count.index + (var.num_subnets * 2))
  tags = {
    Name = "${var.prefix}-data-${count.index}"
  }
}