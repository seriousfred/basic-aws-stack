
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

