variable "aws_profile" {
  description = "AWS_PROFILE (see ~/.aws/credentials)"
  type        = string
}

variable "aws_region" {
  description = "AWS_REGION"
  type        = string
}

variable "prefix" {
  description = "Some prefix for the names of the resources to be created"
  type        = string
  validation {
    condition     = length(var.prefix) < 20
    error_message = "20 chars is enough for a prefix"
  }
}

variable "vpc_id" {
  description = "ID of an existing VPC to use, or leave empty to create a new one."
  type        = string
}

