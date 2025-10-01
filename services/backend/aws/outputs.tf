output "new_task_definition_arn" {
  description = "ARN of the updated task definition"
  value       = aws_ecs_task_definition.updated.arn
}

output "new_task_definition_revision" {
  description = "Revision number of the updated task definition"
  value       = aws_ecs_task_definition.updated.revision
}

output "task_definition_family" {
  description = "Family name of the updated task definition"
  value       = aws_ecs_task_definition.updated.family
}