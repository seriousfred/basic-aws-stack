variable "prefix" {
  description = "Prefix"
  type        = string
}

variable "name" {
  description = "Task Definition name"
  type        = string
}

variable "s3_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket name"
  type        = string
}

variable "cpu" {
  description = "CPU"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory"
  type        = number
  default     = 512
}

variable "repo" {
  description = "ECR repository"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "port" {
  description = "Port"
  type        = number
  default     = 8080
}