resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.encryption_configuration != null ? [var.encryption_configuration.rule] : []
    content {
      apply_server_side_encryption_by_default {
        kms_master_key_id = rule.value.apply_server_side_encryption_by_default.kms_master_key_id
        sse_algorithm     = rule.value.apply_server_side_encryption_by_default.sse_algorithm
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "main" {
  count  = var.versioning != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning.enabled ? "Enabled" : "Disabled"
  }
}