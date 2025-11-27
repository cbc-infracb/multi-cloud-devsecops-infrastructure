resource "aws_ecr_repository" "main" {
  for_each = toset(var.repository_names)

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  dynamic "encryption_configuration" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      encryption_type = "KMS"
      kms_key         = var.kms_key_arn
    }
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "main" {
  for_each = aws_ecr_repository.main

  repository = each.value.name
  policy     = jsonencode(var.lifecycle_policy)
}