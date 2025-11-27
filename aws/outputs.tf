output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "ecr_repository_urls" {
  description = "URLs of ECR repositories"
  value       = module.ecr.repository_urls
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.dns_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.endpoint
}

output "s3_logs_bucket_name" {
  description = "Name of the S3 logs bucket"
  value       = module.s3_logs.bucket_name
}

output "kms_key_arns" {
  description = "ARNs of KMS keys"
  value = {
    eks_cluster = module.kms.cluster_kms_key_arn
    rds         = module.kms.rds_kms_key_arn
    s3          = module.kms.s3_kms_key_arn
    secrets     = module.kms.secrets_kms_key_arn
  }
}