variable "key_specs" {
  description = "Map of KMS key specifications"
  type = map(object({
    description = string
    usage       = string
  }))
  default = {}
}

variable "deletion_window_in_days" {
  description = "Waiting period for key deletion"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}