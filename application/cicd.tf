data "aws_caller_identity" "current" {}

locals {
  resource_name_prefix          = substr(lower(replace("${var.project_name}-${var.environment}", "_", "-")), 0, 32)
  github_connection_name        = coalesce(var.github_connection_name, "${local.resource_name_prefix}-github")
  pipeline_name                 = "${local.resource_name_prefix}-website"
  pipeline_artifact_bucket_name = "${substr(local.resource_name_prefix, 0, 24)}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-artifacts"
  website_bucket_arn            = "arn:aws:s3:::${var.website_bucket_name}"
}

resource "aws_codestarconnections_connection" "github" {
  name          = local.github_connection_name
  provider_type = "GitHub"

  tags = local.common_tags
}

resource "aws_iam_role" "codepipeline" {
  name = "${local.resource_name_prefix}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${local.resource_name_prefix}-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.pipeline_artifacts.arn,
          "${aws_s3_bucket.pipeline_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = aws_codestarconnections_connection.github.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.website_deploy.arn
      }
    ]
  })
}

resource "aws_iam_role" "codebuild" {
  name = "${local.resource_name_prefix}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${local.resource_name_prefix}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.pipeline_artifacts.arn,
          "${aws_s3_bucket.pipeline_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          local.website_bucket_arn,
          "${local.website_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_codebuild_project" "website_deploy" {
  name         = "${local.resource_name_prefix}-website-deploy"
  description  = "Deploys selected repository files to the root of the website S3 bucket."
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "WEBSITE_BUCKET_NAME"
      value = var.website_bucket_name
    }

    environment_variable {
      name  = "WEBSITE_SOURCE_DIRECTORY"
      value = var.website_source_directory
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOT
      version: 0.2

      phases:
        build:
          commands:
            - test -d "$WEBSITE_SOURCE_DIRECTORY"
            - aws s3 sync "$WEBSITE_SOURCE_DIRECTORY/" "s3://$WEBSITE_BUCKET_NAME/" --delete
    EOT
  }

  tags = local.common_tags
}

resource "aws_codepipeline" "website" {
  name     = local.pipeline_name
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        BranchName           = var.github_branch
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        DetectChanges        = "true"
        FullRepositoryId     = var.github_repository_id
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "SyncToS3Root"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.website_deploy.name
      }
    }
  }

  tags = local.common_tags
}
