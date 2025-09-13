output "vpc_id" {
  value = var.vpc_id != "" ? data.aws_vpc.existing_vpc[0].id : aws_vpc.new_vpc[0].id
}

output "public_subnets" {
  value = length(var.public_subnets) == 0 ? [for subnet in aws_subnet.public_subnets : subnet.id] : var.public_subnets
}

output "private_subnets" {
  value = length(var.private_subnets) == 0 ? [for subnet in aws_subnet.private_subnets : subnet.id] : var.private_subnets
}

output "data_subnets" {
  value = length(var.data_subnets) == 0 ? [for subnet in aws_subnet.data_subnets : subnet.id] : var.data_subnets
}