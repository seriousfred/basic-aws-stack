variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to use"
  type        = string
}

variable "github_token" {
  description = "The GitHub token"
  type        = string
}

variable "repository_owner" {
  description = "Github repository owner"
  type        = string
}

variable "repository_name" {
  description = "Github repository name"
  type        = string
}

variable "ecr_repo" {
  description = "ECR repository URL"
  type        = string
}
variable "cluster" {
  description = "ECS cluster name"
  type        = string
}
variable "service" {
  description = "ECS service name"
  type        = string
}

variable "taskdef_family" {
  description = "ECS task definition family name"
  type        = string
}