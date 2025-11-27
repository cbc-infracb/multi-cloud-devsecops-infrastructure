variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "enable_waf" {
  description = "Enable WAF"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable access logging"
  type        = bool
  default     = false
}

variable "log_bucket_name" {
  description = "S3 bucket name for access logs"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "SSL certificate ARN"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "health_check" {
  description = "Health check configuration"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}