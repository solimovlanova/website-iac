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

variable "ecr_repository_names" {
  description = "Names of ECR repositories to create."
  type        = list(string)
  default     = []
}

variable "agent_workspace_aws_region" {
  description = "AWS region for the agent workspace."
  type        = string
  default     = "eu-central-1"
  nullable    = false
}

variable "agent_workspace_name_prefix" {
  description = "Prefix used by agent workspace scheduler and IAM resources."
  type        = string
  default     = "workspace"
  nullable    = false
}

variable "agent_workspace_instance_name" {
  description = "Name tag for the agent workspace EC2 instance."
  type        = string
  default     = "workspace-ec2"
  nullable    = false
}

variable "agent_workspace_instance_type" {
  description = "UEFI-capable x86_64 Nitro EC2 instance type from a supported family."
  type        = string
  default     = "m7i-flex.large"
  nullable    = false
}

variable "agent_workspace_storage" {
  description = "Agent workspace root disk settings."
  type = object({
    size_gb               = optional(number, 30)
    encrypted             = optional(bool, true)
    delete_on_termination = optional(bool, false)
  })
  default = {}
}

variable "agent_workspace_associate_public_ip" {
  description = "Whether to associate a public IPv4 address with the agent workspace instance."
  type        = bool
  default     = false
}

variable "agent_workspace_vpc_id" {
  description = "Optional VPC override for the agent workspace. Use null or default to use the account default VPC."
  type        = string
  default     = null
}

variable "agent_workspace_subnet_id" {
  description = "Optional subnet override for the agent workspace. If null, the default VPC first subnet is used."
  type        = string
  default     = null
}

variable "agent_workspace_security_group_ids" {
  description = "Optional security groups override for the agent workspace. If empty, the module creates a security group."
  type        = list(string)
  default     = []
}

variable "agent_workspace_ingress_ports" {
  description = "Generated agent workspace security group ingress rules."
  type = list(object({
    protocol         = string
    port             = optional(number)
    from_port        = optional(number)
    to_port          = optional(number)
    description      = optional(string)
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    security_groups  = optional(list(string), [])
    self             = optional(bool, false)
  }))
  default = []
}

variable "agent_workspace_egress_ports" {
  description = "Generated agent workspace security group egress rules."
  type = list(object({
    port     = number
    protocol = string
  }))
  default = [
    { port = 443, protocol = "tcp" },
    { port = 80, protocol = "tcp" },
    { port = 41641, protocol = "udp" }
  ]
}

variable "agent_workspace_ami_id" {
  description = "Optional explicit AMI ID for the agent workspace instance."
  type        = string
  default     = null
}

variable "agent_workspace_instance_schedule_windows" {
  description = "Allowed agent workspace run windows. Defaults to the module scheduler: weekday evenings and weekends in Europe/Berlin."
  type = list(object({
    name       = string
    mode       = optional(string, "free-time")
    timezone   = string
    days       = list(string)
    start_time = string
    stop_time  = string
  }))
  default = [
    {
      name       = "free_time"
      mode       = "free-time"
      timezone   = "Europe/Berlin"
      days       = ["MON", "TUE", "WED", "THU", "FRI"]
      start_time = "18:30"
      stop_time  = "23:00"
    },
    {
      name       = "weekends"
      mode       = "free-time"
      timezone   = "Europe/Berlin"
      days       = ["SAT", "SUN"]
      start_time = "11:00"
      stop_time  = "22:00"
    }
  ]
}

variable "agent_workspace_developer_config" {
  description = "Developer tooling installed or configured during agent workspace bootstrap."
  type = object({
    install_vscode      = optional(bool, true)
    enable_tailscale    = optional(bool, true)
    install_claude_code = optional(bool, true)
    install_codex_cli   = optional(bool, false)
  })
  default = {}
}

variable "agent_workspace_extra_env_vars" {
  description = "Uppercase environment variable names for which the module creates SSM SecureString placeholder parameters."
  type        = set(string)
  default     = []
}

variable "agent_workspace_extra_env_var_parameter_names" {
  description = "Map of uppercase environment variable names to existing SSM Parameter Store SecureString names."
  type        = map(string)
  default     = {}
}

variable "agent_workspace_enable_session_manager" {
  description = "Enable AWS Systems Manager Session Manager for agent workspace access."
  type        = bool
  default     = true
}

variable "agent_workspace_ami_transfer" {
  description = "Manual AMI copy/export settings for the latest agent workspace AMI."
  type = object({
    enable_copy           = optional(bool, false)
    copy_target_region    = optional(string, "")
    enable_export         = optional(bool, false)
    export_s3_bucket      = optional(string, "")
    create_export_bucket  = optional(bool, true)
    export_s3_prefix      = optional(string, "ami-exports")
    export_disk_format    = optional(string, "VMDK")
    export_retention_days = optional(number, 30)
    export_role_name      = optional(string, "vmimport")
  })
  default = {}
}

variable "agent_workspace_scheduler_features" {
  description = "Optional scheduled agent workspace maintenance jobs. Defaults to reconcile only."
  type = object({
    reconcile                     = optional(bool, true)
    daily_snapshots               = optional(bool, false)
    weekly_amis                   = optional(bool, false)
    monthly_amis                  = optional(bool, false)
    backup_cleanup                = optional(bool, false)
    security_update               = optional(bool, false)
    maintenance_timezone          = optional(string, "Europe/Berlin")
    daily_snapshot_retention_days = optional(number, 7)
    monthly_ami_retention_days    = optional(number, 30)
  })
  default = {}
}

variable "agent_workspace_kms_key_arn" {
  description = "Optional KMS key ARN to encrypt all agent workspace module-managed resources."
  type        = string
  default     = null
}

variable "agent_workspace_environment" {
  description = "Environment tag used by the agent workspace module."
  type        = string
  default     = "dev"
  nullable    = false
}

variable "agent_workspace_cost_center" {
  description = "Cost center tag value for agent workspace billing attribution."
  type        = string
  default     = "engineering"
  nullable    = false
}

variable "agent_workspace_owner_email" {
  description = "Owner tag value used to identify agent workspace operational responsibility."
  type        = string
  default     = "owner@example.com"
  nullable    = false
}

variable "agent_workspace_cost_report" {
  description = "Native AWS Budgets cost alert configuration for the agent workspace."
  type = object({
    enabled                  = optional(bool, false)
    email_addresses          = optional(list(string), [])
    monthly_budget_limit_usd = optional(number, 100)
    alert_threshold_percent  = optional(number, 80)
  })
  default = {}
}

variable "agent_workspace_tags" {
  description = "Additional tags applied only to agent workspace resources."
  type        = map(string)
  default     = {}
}
