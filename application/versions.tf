terraform {
  required_version = ">= 1.8.0"

  cloud {
    organization = "Soli"

    workspaces {
      name = "website"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}