aws_region   = "us-east-1"
project_name = "website"
environment  = "prod"

tags = {
  Owner = "team-name"
}

github_repository_id     = "solimovlanova/website-iac"
github_branch            = "main"
website_source_directory = "website"
website_bucket_name      = "replace-with-existing-prod-website-bucket-name"
