variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public policy"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public buckets"
  type        = bool
  default     = true
}

variable "encryption_configuration" {
  description = "Encryption configuration"
  type        = any
  default     = null
}

variable "versioning" {
  description = "Versioning configuration"
  type = object({
    enabled = bool
  })
  default = null
}

variable "lifecycle_configuration" {
  description = "Lifecycle configuration"
  type        = any
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}