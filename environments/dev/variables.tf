variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in tags and resource names."
  type        = string
  default     = "website"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Extra tags applied to all AWS resources."
  type        = map(string)
  default     = {}
}

variable "github_repository_id" {
  description = "Full GitHub repository id in owner/repository format."
  type        = string
}

variable "github_branch" {
  description = "Git branch that triggers the deployment pipeline."
  type        = string
  default     = "main"
}

variable "website_source_directory" {
  description = "Repository directory whose contents are deployed to the root of the website S3 bucket."
  type        = string
  default     = "website"
}

variable "website_bucket_name" {
  description = "Name of the existing destination S3 bucket for website files."
  type        = string
}

variable "github_connection_name" {
  description = "Name for the AWS CodeConnections GitHub connection."
  type        = string
  default     = null
}
