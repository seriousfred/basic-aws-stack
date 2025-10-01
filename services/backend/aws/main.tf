
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_ecs_task_definition" "current" {
  task_definition = var.task_definition_family
}

# Get the current task definition to extract existing configuration
locals {
  # Parse the current task definition
  current_container_definitions = jsondecode(data.aws_ecs_task_definition.current.container_definitions)

  # Update the image and environment variables for the backend container
  updated_container_definitions = [
    for container in local.current_container_definitions : {
      name      = container.name
      image     = container.name == var.container_name ? var.new_image_uri : container.image
      cpu       = try(container.cpu, null)
      memory    = try(container.memory, null)
      essential = try(container.essential, true)

      # Preserve existing configuration and merge with new environment variables and secrets
      portMappings = try(container.portMappings, [])
      environment  = container.name == var.container_name ? local.merged_environment_variables : try(container.environment, [])
      secrets      = container.name == var.container_name ? local.merged_secrets : try(container.secrets, [])
      logConfiguration = try(container.logConfiguration, null)
      healthCheck  = try(container.healthCheck, null)
      mountPoints  = try(container.mountPoints, [])
      volumesFrom  = try(container.volumesFrom, [])
    }
  ]

  # Merge existing environment variables with new ones
  existing_env_vars = {
    for env in try(local.current_container_definitions[
      index(local.current_container_definitions[*].name, var.container_name)
    ].environment, []) : env.name => env.value
  }
  
  merged_env_vars = merge(local.existing_env_vars, var.environment_variables)
  
  merged_environment_variables = [
    for name, value in local.merged_env_vars : {
      name  = name
      value = value
    }
  ]

  # Merge existing secrets with new ones
  existing_secrets = {
    for secret in try(local.current_container_definitions[
      index(local.current_container_definitions[*].name, var.container_name)
    ].secrets, []) : secret.name => secret.valueFrom
  }
  
  merged_secrets_map = merge(local.existing_secrets, var.secrets)
  
  merged_secrets = [
    for name, valueFrom in local.merged_secrets_map : {
      name      = name
      valueFrom = valueFrom
    }
  ]
}

resource "aws_ecs_task_definition" "updated" {

  family                   = data.aws_ecs_task_definition.current.family
  network_mode             = data.aws_ecs_task_definition.current.network_mode
  requires_compatibilities = data.aws_ecs_task_definition.current.requires_compatibilities
  cpu                      = data.aws_ecs_task_definition.current.cpu
  memory                   = data.aws_ecs_task_definition.current.memory
  execution_role_arn       = data.aws_ecs_task_definition.current.execution_role_arn
  task_role_arn            = data.aws_ecs_task_definition.current.task_role_arn

  container_definitions = jsonencode(local.updated_container_definitions)


  tags = {
    Environment = var.environment
    Service     = var.container_name
    UpdatedBy   = "terraform"
    UpdatedAt   = timestamp()
  }

}