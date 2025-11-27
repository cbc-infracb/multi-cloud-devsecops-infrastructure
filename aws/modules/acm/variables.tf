variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
  default     = ""
}

variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}