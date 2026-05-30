aws_region   = "us-east-1"
project_name = "website"
environment  = "dev"

tags = {
  Owner = "soli"
}

github_repository_id     = "solimovlanova/draft-project1"
github_branch            = "master"
website_source_directory = "s3"
website_bucket_name      = "movlanova.com"

ecr_repository_names = ["calculator"]
