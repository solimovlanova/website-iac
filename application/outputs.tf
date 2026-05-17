output "aws_region" {
  description = "Configured AWS region."
  value       = var.aws_region
}

output "common_tags" {
  description = "Merged default tags applied to resources."
  value       = local.common_tags
}

output "website_bucket_name" {
  description = "Existing destination S3 bucket for website files."
  value       = var.website_bucket_name
}

output "github_connection_arn" {
  description = "AWS CodeConnections ARN to authorize with GitHub after the first apply."
  value       = aws_codestarconnections_connection.github.arn
}

output "codepipeline_name" {
  description = "Name of the website deployment pipeline."
  value       = aws_codepipeline.website.name
}
