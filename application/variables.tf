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