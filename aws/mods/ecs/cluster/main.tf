resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {

  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

}