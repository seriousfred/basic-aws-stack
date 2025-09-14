variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "create_alb" {
  description = "Set to true to create an ALB"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "Subnets IDs for ALB"
  type        = list(any)
  default     = []
}
