## placeholder

provider "aws" {
  profile = "jeevan-master"
  region  = var.aws_region
  default_tags {
    tags = {
      env        = "prod"
      managed_by = "terraform"
    }
  }
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }
  backend "s3" {
    key     = "prod/account-bootstrap/terraform.tfstate"
    bucket  = "jeevan-personal-training-terraform-statefiles"
    region  = "us-east-1"
    profile = "jeevan-master"
  }
}

