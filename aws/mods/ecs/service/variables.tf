variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "name" {
  description = "Service name"
  type        = string
}

variable "desired_count" {
  description = "Desired count of tasks"
  type        = string
}

variable "cluster" {
  description = "ECS cluster name"
  type        = string
}

variable "task_definition" {
  description = "Task definition ARN"
  type        = string
}

variable "port" {
  description = "Port"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnets" {
  description = "The subnets to deploy the service into"
  type        = list(string)
}

variable "listener_arn" {
  description = "ALB Listener ARN"
  type        = string
}

variable "listener_priority" {
  description = "ALB Listener priority"
  type        = string
}

variable "alarm_topic_arn" {
  description = "SNS Topic ARN for alarm notifications"
  type        = string
}