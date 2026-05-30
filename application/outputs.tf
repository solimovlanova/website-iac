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

output "web_instance_id" {
  description = "EC2 instance id for the web origin."
  value       = aws_instance.web.id
}

output "web_session_manager_command" {
  description = "AWS CLI command to start a Session Manager shell on the web origin."
  value       = "aws ssm start-session --target ${aws_instance.web.id} --region ${var.aws_region}"
}

output "web_eip_allocation_id" {
  description = "Allocation id for the persistent web Elastic IP."
  value       = aws_eip.web.id
}

output "web_public_ip" {
  description = "Persistent public IPv4 address assigned to the web origin."
  value       = aws_eip.web.public_ip
}

output "ecr_repository_urls" {
  description = "Repository URLs for the created ECR repositories."
  value = {
    for name, repository in aws_ecr_repository.repositories :
    name => repository.repository_url
  }
}
