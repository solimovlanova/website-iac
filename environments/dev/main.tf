terraform {
  cloud {
    organization = "Soli"

    workspaces {
      name = "website-iac"
    }
  }
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
}
