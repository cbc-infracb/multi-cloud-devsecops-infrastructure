output "key_arns" {
  description = "Map of KMS key ARNs"
  value       = { for k, v in aws_kms_key.main : k => v.arn }
}

output "key_ids" {
  description = "Map of KMS key IDs"
  value       = { for k, v in aws_kms_key.main : k => v.key_id }
}

output "cluster_kms_key_arn" {
  description = "ARN of the EKS cluster KMS key"
  value       = try(aws_kms_key.main["eks_cluster"].arn, null)
}

output "rds_kms_key_arn" {
  description = "ARN of the RDS KMS key"
  value       = try(aws_kms_key.main["rds"].arn, null)
}

output "s3_kms_key_arn" {
  description = "ARN of the S3 KMS key"
  value       = try(aws_kms_key.main["s3"].arn, null)
}

output "secrets_kms_key_arn" {
  description = "ARN of the Secrets Manager KMS key"
  value       = try(aws_kms_key.main["secrets"].arn, null)
}