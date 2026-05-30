output "web_instance_id" {
  description = "EC2 instance id for the web origin."
  value       = module.application.web_instance_id
}

output "web_session_manager_command" {
  description = "AWS CLI command to start a Session Manager shell on the web origin."
  value       = module.application.web_session_manager_command
}

output "web_eip_allocation_id" {
  description = "Allocation id for the persistent web Elastic IP."
  value       = module.application.web_eip_allocation_id
}

output "web_public_ip" {
  description = "Persistent public IPv4 address assigned to the web origin."
  value       = module.application.web_public_ip
}

output "ecr_repository_urls" {
  description = "Repository URLs for the created ECR repositories."
  value       = module.application.ecr_repository_urls
}
