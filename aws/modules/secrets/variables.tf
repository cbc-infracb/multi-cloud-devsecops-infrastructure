variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

variable "database_secrets" {
  description = "Database secrets"
  type        = map(string)
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}