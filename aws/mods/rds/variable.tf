variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to deploy the RDS instance into"
  type        = string
}

variable "subnets" {
  description = "The subnets to deploy the RDS instance into"
  type        = list(string)
}

variable "allowed_subnets" {
  description = "The subnets to communicate with the RDS instance"
  type        = list(string)
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t4g.small"
}

variable "database_storage" {
  description = "The storage size for the RDS instance"
  type        = number
  default     = 20
}

variable "database_port" {
  description = "The database port for the RDS instance"
  type        = number
  default     = 5432
}

variable "database_name" {
  description = "The name of the default database to create"
  type        = string
  default     = "test"
}

variable "database_username" {
  description = "The name of the default database user"
  type        = string
  default     = "test"
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for the RDS instance"
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Whether to create a Multi-AZ RDS instance"
  type        = bool
  default     = false
}

variable "alarm_topic_arn" {
  description = "SNS Topic ARN for alarm notifications"
  type        = string
}