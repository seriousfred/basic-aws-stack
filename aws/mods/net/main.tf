
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

# connectivity
resource "aws_internet_gateway" "igw" {
  count  = var.vpc_id == "" ? 1 : 0
  vpc_id = aws_vpc.new_vpc[0].id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

# public subnets
resource "aws_default_route_table" "rt_public" {
  count                  = var.vpc_id == "" ? 1 : 0
  default_route_table_id = aws_vpc.new_vpc[0].default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = {
    Name = "${var.prefix}-rtb-public"
  }
}

resource "aws_route_table_association" "rt_assoc_pub_subnets" {
  count          = var.vpc_id == "" ? var.num_subnets : 0
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_vpc.new_vpc[0].main_route_table_id
}

# private subnets
resource "aws_eip" "eip" {
  count = var.vpc_id == "" ? var.num_subnets : 0
  vpc   = true
  tags  = {
    Name = "${var.prefix}-natgw-${count.index}"
  }
}

resource "aws_nat_gateway" "natgw" {
  count         = var.vpc_id == "" ? var.num_subnets : 0
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  tags = {
    Name = "${var.prefix}-natgw-${count.index}"
  }
}

resource "aws_route_table" "rt_private" {

  count  = var.vpc_id == "" ? var.num_subnets : 0
  vpc_id = aws_vpc.new_vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = {
    Name = "${var.prefix}-rt-private-${count.index}"
  }

}

resource "aws_route_table_association" "rt_assoc_private_subnets" {

  count          = var.vpc_id == "" ? var.num_subnets : 0
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.rt_private[count.index].id

}