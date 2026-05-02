output "aws_region" {
  description = "Configured AWS region."
  value       = var.aws_region
}

output "common_tags" {
  description = "Merged default tags applied to resources."
  value       = local.common_tags
}