
terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47"
    }
  }

  cloud {
    organization = "Soli"

    workspaces {
      name = "website-iac"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "agent_workspace"
  region = var.agent_workspace_aws_region
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


module "agent_workspace" {
  source = "../../modules/agent-workspace"

  providers = {
    aws = aws.agent_workspace
  }

  aws_region                    = var.agent_workspace_aws_region
  name_prefix                   = var.agent_workspace_name_prefix
  instance_name                 = var.agent_workspace_instance_name
  instance_type                 = var.agent_workspace_instance_type
  storage                       = var.agent_workspace_storage
  associate_public_ip           = var.agent_workspace_associate_public_ip
  vpc_id                        = var.agent_workspace_vpc_id
  subnet_id                     = var.agent_workspace_subnet_id
  security_group_ids            = var.agent_workspace_security_group_ids
  ingress_ports                 = var.agent_workspace_ingress_ports
  egress_ports                  = var.agent_workspace_egress_ports
  ami_id                        = var.agent_workspace_ami_id
  developer_config              = var.agent_workspace_developer_config
  instance_schedule_windows     = var.agent_workspace_instance_schedule_windows
  scheduler_features            = var.agent_workspace_scheduler_features
  extra_env_vars                = var.agent_workspace_extra_env_vars
  extra_env_var_parameter_names = var.agent_workspace_extra_env_var_parameter_names
  kms_key_arn                   = var.agent_workspace_kms_key_arn
  cost_report                   = var.agent_workspace_cost_report
  ami_transfer                  = var.agent_workspace_ami_transfer
  enable_session_manager        = var.agent_workspace_enable_session_manager
  environment                   = var.agent_workspace_environment
  cost_center                   = var.agent_workspace_cost_center
  owner_email                   = var.agent_workspace_owner_email
  tags                          = merge(var.tags, var.agent_workspace_tags)
}
