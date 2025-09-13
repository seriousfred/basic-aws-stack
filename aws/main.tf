
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
module "net" {
  source = "./mods/net"
  vpc_id = var.vpc_id # will create resources if not empty
  prefix  = var.prefix
  cidr   = "10.42.0.0/16"
}



# rds
module "rds" {
  source = "./mods/rds"
  prefix = var.prefix
  vpc_id = module.net.vpc_id
  subnets = module.net.data_subnets
  allowed_subnets = module.net.private_subnets
}

# s3
module "s3" {
  source = "./mods/s3"
  bucket_name = "${var.prefix}-${var.aws_region}-${random_id.RANDOM_ID.hex}"
}


# ecr
module "ecr" {
  source = "./mods/ecr"
  repo_name = "${var.prefix}/services-${random_id.RANDOM_ID.hex}"
}

# ecs cluster
module "ecs_cluster" {
  source = "./mods/ecs/cluster"
  prefix = var.prefix
}

# task definition
module "ecs_task_def" {
  source = "./mods/ecs/task-def"
  prefix = var.prefix
  name = "service-${random_id.RANDOM_ID.hex}"
  repo = module.ecr.ecr_repository_url
  aws_region = var.aws_region
  port = 8080
  s3_arn = module.s3.s3_bucket_arn
  s3_bucket = module.s3.s3_bucket_id
}

