
terraform {
  cloud {
    organization = "Soli"

    workspaces {
      name = "website-iac"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
import {
  to = module.application.aws_codestarconnections_connection.github
  id = "arn:aws:codeconnections:us-east-1:299834554281:connection/e5d83352-d991-4938-b9af-7979a05f0cf4"
}

module "application" {
  source = "../../application"

  aws_region               = var.aws_region
  project_name             = var.project_name
  environment              = var.environment
  tags                     = var.tags
  github_repository_id     = var.github_repository_id
  github_branch            = var.github_branch
  website_source_directory = var.website_source_directory
  website_bucket_name      = var.website_bucket_name
  github_connection_name   = var.github_connection_name
  ecr_repository_names     = var.ecr_repository_names
}


import {
  to = module.application.aws_s3_bucket.website
  id = "movlanova.com"
  
}

import {
  to = module.application.aws_s3_bucket_ownership_controls.website
  id = "movlanova.com"
}

# import {
#   to = module.application.aws_s3_bucket_acl.website
#   id = "movlanova.com"
# }

import {
  to = module.application.aws_s3_bucket_policy.website
  id = "movlanova.com"
}

import {
  to = module.application.aws_s3_bucket_public_access_block.website
  id = "movlanova.com"
}
