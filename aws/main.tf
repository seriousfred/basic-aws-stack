
# providers
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# utilities
resource "random_id" "RANDOM_ID" {
  byte_length = "6"
}

# modules
# network
module "net" {
  source = "./mods/net"
  vpc_id = var.vpc_id
  prefix = var.prefix
  cidr   = "10.42.0.0/16"
}

# rds
module "rds" {
  source          = "./mods/rds"
  prefix          = var.prefix
  vpc_id          = module.net.vpc_id
  subnets         = module.net.data_subnets
  allowed_subnets = module.net.private_subnets
  alarm_topic_arn = module.sns.sns_arn
}

# load balancer
# @todo conditionally create ALB (shoud receive listener_arn)
module "alb" {
  source     = "./mods/alb"
  create_alb = true
  prefix     = var.prefix
  vpc_id     = module.net.vpc_id
  subnets    = module.net.public_subnets
}

# s3
module "s3" {
  source      = "./mods/s3"
  bucket_name = "${var.prefix}-${var.aws_region}-${random_id.RANDOM_ID.hex}"
}

# sns
module "sns" {
  source     = "./mods/sns"
  topic_name = "${var.prefix}-alerts-${random_id.RANDOM_ID.hex}"
}

# ecr
module "ecr" {
  source    = "./mods/ecr"
  repo_name = "${var.prefix}/services-${random_id.RANDOM_ID.hex}"
}

# ecs cluster
module "ecs_cluster" {
  source = "./mods/ecs/cluster"
  prefix = var.prefix
}

# task definition
module "ecs_task_def" {
  source     = "./mods/ecs/task-def"
  prefix     = var.prefix
  name       = "service-${random_id.RANDOM_ID.hex}"
  repo       = module.ecr.ecr_repository_url
  aws_region = var.aws_region
  port       = 8080
  s3_arn     = module.s3.s3_bucket_arn
  s3_bucket  = module.s3.s3_bucket_id
}

# service
module "ecs_service" {
  source            = "./mods/ecs/service"
  prefix            = var.prefix
  name              = "service-${random_id.RANDOM_ID.hex}"
  desired_count     = "1"
  cluster           = module.ecs_cluster.ecs_cluster_id
  task_definition   = module.ecs_task_def.arn_task_definition
  port              = 8080
  vpc_id            = module.net.vpc_id
  subnets           = module.net.private_subnets
  listener_arn      = module.alb.listener_arn
  listener_priority = 1
  alarm_topic_arn   = module.sns.sns_arn
}

# devops stuffs
module "devops" {
  source           = "./mods/devops"
  prefix           = var.prefix
  github_token     = var.github_token
  repository_owner = var.repository_owner
  repository_name  = var.repository_name
  ecr_repo         = module.ecr.ecr_repository_url
  aws_region       = var.aws_region
  cluster          = module.ecs_cluster.ecs_cluster_name
  service          = "service-${random_id.RANDOM_ID.hex}"
}

