
# providers

provider "aws" {
  
  profile = var.aws_profile
  region  = var.aws_region

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

# ecs cluster
module "ecs_cluster" {
  source = "./mods/ecs/cluster"
  prefix = var.prefix
}

