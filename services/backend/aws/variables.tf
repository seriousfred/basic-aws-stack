variable "task_definition_family" {
  description = "Family name of the existing task definition to update"
  type        = string
}

variable "container_name" {
  description = "Name of the container to update in the task definition"
  type        = string
  default     = "backend"
}

variable "new_image_uri" {
  description = "New container image URI to deploy"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment_variables" {
  description = "Environment variables to add/override in the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets to add/override in the container (name -> valueFrom ARN)"
  type        = map(string)
  default     = {}
}