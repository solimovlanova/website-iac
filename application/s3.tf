resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = local.pipeline_artifact_bucket_name

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
