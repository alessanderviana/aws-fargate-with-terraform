terraform {
  required_version = ">= 0.13"

  # required_providers {
  #   aws = {
  #     source  = "hashicorp/aws"
  #     version = "~> 2.47"
  #   }
  #   region = var.aws_region
  #   profile = var.aws_profile
  # }
}

provider "aws" {
  version = "~> 2.12"
  region = var.aws_region
  profile = var.aws_profile
}
