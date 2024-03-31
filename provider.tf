terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.9"
    }
  }
}

provider "aws" {
  region              = "us-east-1"
  shared_config_files = ["%USERPROFILE%/.aws/credentials"]
  profile             = "terraformuser"
}