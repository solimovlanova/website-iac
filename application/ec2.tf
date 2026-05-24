####################################################
# Public EC2 origin restricted to Cloudflare
####################################################

data "aws_ssm_parameter" "ubuntu_2404_arm64" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/arm64/hvm/ebs-gp3/ami-id"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "http" "cloudflare_ipv4" {
  url = "https://www.cloudflare.com/ips-v4"
}

locals {
  cloudflare_ipv4_cidrs          = split("\n", trimspace(data.http.cloudflare_ipv4.response_body))
  cloudflare_ipv4_cidrs_per_sg   = 30
  cloudflare_ipv4_security_groups = chunklist(local.cloudflare_ipv4_cidrs, local.cloudflare_ipv4_cidrs_per_sg)
  cloudflare_ipv4_ingress_rules = flatten([
    for sg_index, cidrs in local.cloudflare_ipv4_security_groups : [
      for cidr in cidrs : [
        for port in [80, 443] : {
          key      = "${sg_index}-${port}-${cidr}"
          sg_index = tostring(sg_index)
          cidr     = cidr
          port     = port
        }
      ]
    ]
  ])
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-${var.environment}-web-sg-${each.key}"
  description = "Allow web traffic only from Cloudflare; no direct SSH"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-web-sg-${each.key}"
  })

  for_each = {
    for index, cidrs in local.cloudflare_ipv4_security_groups : tostring(index) => cidrs
  }
}

resource "aws_vpc_security_group_ingress_rule" "cloudflare_web_ipv4" {
  security_group_id = aws_security_group.web[each.value.sg_index].id
  description       = "Port ${each.value.port} from Cloudflare IPv4"
  ip_protocol       = "tcp"
  from_port         = each.value.port
  to_port           = each.value.port
  cidr_ipv4         = each.value.cidr

  for_each = {
    for rule in local.cloudflare_ipv4_ingress_rules : rule.key => rule
  }
}

resource "aws_vpc_security_group_egress_rule" "http_ipv4" {
  security_group_id = aws_security_group.web["0"].id
  description       = "Outbound HTTP for package repositories"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "https_ipv4" {
  security_group_id = aws_security_group.web["0"].id
  description       = "Outbound HTTPS for updates and SSM"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_iam_role" "ec2_ssm" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.ubuntu_2404_arm64.value
  instance_type               = "t4g.small"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [for security_group in values(aws_security_group.web) : security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  associate_public_ip_address = true
  monitoring                  = true
  disable_api_termination     = true

  user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    if ! command -v snap >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y snapd
    fi

    if ! snap list amazon-ssm-agent >/dev/null 2>&1; then
      snap install amazon-ssm-agent --classic
    fi

    systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service
  EOT

  lifecycle {
    precondition {
      condition     = length(local.cloudflare_ipv4_security_groups) <= 5
      error_message = "Cloudflare IPv4 ranges need more than 5 security groups. Request a higher AWS security groups per network interface quota or use an AWS managed prefix list/WAF design."
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-web"
  })
}

resource "aws_eip" "web" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-web-eip"
  })
}

resource "aws_eip_association" "web" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web.id
}
