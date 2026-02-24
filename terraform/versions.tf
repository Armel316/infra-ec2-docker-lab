terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket  = "armel-s3-lab"
    key     = "infra/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}