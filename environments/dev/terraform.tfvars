aws_region   = "eu-central-1"
project_name = "website"
environment  = "dev"

tags = {
  Owner = "soli"
}

github_repository_id     = "solimovlanova/draft-project1"
github_branch            = "master"
website_source_directory = "s3"
website_bucket_name      = "movlanova.com"

ecr_repository_names = ["calculator", "md2pdf"]

agent_workspace_aws_region          = "eu-central-1"
agent_workspace_name_prefix         = "agent-workspace"
agent_workspace_instance_name       = "agent-workspace-ec2"
agent_workspace_associate_public_ip = true

agent_workspace_tags = {
  Service = "agent-workspace"
}
