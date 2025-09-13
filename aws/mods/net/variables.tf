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

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = []
}

variable "data_subnets" {
  description = "List of data subnet IDs"
  type        = list(string)
  default     = []
}