variable "prefix" {
  description = "Prefix"
  type        = string
}

variable "vpc_id" {
  description = "ID of existing VPC to use"
  type        = string
}

variable "cidr" {
  description = "CIDR block"
  type        = string
}

variable "num_subnets" {
  description = "Number of subnets to create"
  default     = 2
}