provider "aws" {
  region    = var.AWS_REGION
}

terraform {
#  backend "s3" {
#    bucket = "tf-backend"
#    key    = "tf/wl-infra-state"
#    region = "us-east-1"
#  }

  required_version = "~> 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
  }
}
