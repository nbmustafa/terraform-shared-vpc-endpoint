provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  profile    = "default"
  region     = "us-east-1"
}

terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}
