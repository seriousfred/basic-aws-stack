terraform {

  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }    
  }

}