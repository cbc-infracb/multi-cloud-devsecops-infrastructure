resource "aws_secretsmanager_secret" "database" {
  name        = "${var.name_prefix}-database-credentials"
  description = "Database credentials"
  kms_key_id  = var.kms_key_id

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id     = aws_secretsmanager_secret.database.id
  secret_string = jsonencode(var.database_secrets)
}