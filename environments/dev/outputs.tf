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

output "agent_workspace_instance_id" {
  description = "EC2 instance id for the agent workspace."
  value       = module.agent_workspace.instance_id
}

output "agent_workspace_session_manager_command" {
  description = "AWS CLI command to start a Session Manager shell on the agent workspace."
  value       = module.agent_workspace.ssm_start_session_command
}

output "agent_workspace_public_ip" {
  description = "Public IP address for the agent workspace, if assigned."
  value       = module.agent_workspace.instance_public_ip
}

output "agent_workspace_scheduler_names" {
  description = "EventBridge Scheduler schedules created for the agent workspace."
  value       = module.agent_workspace.scheduler_names
}

output "agent_workspace_log_group_name" {
  description = "CloudWatch log group for agent workspace bootstrap and instance logs."
  value       = module.agent_workspace.workspace_log_group_name
}
