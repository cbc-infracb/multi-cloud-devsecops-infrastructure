terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
  }
}

data "aws_caller_identity" "current" {}

# KMS Keys for different services
resource "aws_kms_key" "main" {
  for_each = var.key_specs

  description             = each.value.description
  key_usage               = each.value.usage
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${each.key}-key"
  })
}

# KMS Key Aliases
resource "aws_kms_alias" "main" {
  for_each = var.key_specs

  name          = "alias/${each.key}-key"
  target_key_id = aws_kms_key.main[each.key].key_id
}