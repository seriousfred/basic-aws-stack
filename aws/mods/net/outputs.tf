output "vpc_id" {
  value = var.vpc_id != "" ? data.aws_vpc.existing_vpc[0].id : aws_vpc.new_vpc[0].id
}
