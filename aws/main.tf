
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


