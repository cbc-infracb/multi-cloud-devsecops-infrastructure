terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Generate random suffix for globally unique names
resource "random_id" "suffix" {
  byte_length = 4
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  common_tags = {
    Environment     = var.environment
    Project         = var.project_name
    ManagedBy       = "Terraform"
    BusinessUnit    = var.business_unit
    CostCenter      = var.cost_center
    Owner           = var.owner_email
    CreatedDate     = formatdate("YYYY-MM-DD", timestamp())
    WellArchitected = "true"
  }

  resource_prefix = "${var.project_name}-${var.environment}"
  random_suffix   = lower(random_id.suffix.hex)
  account_id      = data.aws_caller_identity.current.account_id
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name_prefix        = local.resource_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names

  # Subnet configurations
  private_subnet_cidrs  = var.private_subnet_cidrs
  public_subnet_cidrs   = var.public_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs

  # Enable VPC features for security and performance
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "production"
  enable_vpn_gateway   = false

  # VPC Flow Logs for security monitoring
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  tags = local.common_tags
}

# EKS Cluster Module
module "eks" {
  source = "./modules/eks"

  cluster_name    = "${local.resource_prefix}-eks"
  cluster_version = var.eks_cluster_version

  # Network configuration
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  control_plane_subnet_ids        = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = var.environment == "production" ? false : true

  # Security configurations
  cluster_encryption_config = [{
    provider_key_arn = module.kms.cluster_kms_key_arn
    resources        = ["secrets"]
  }]

  # Managed node groups
  managed_node_groups = {
    main = {
      name           = "main-ng"
      instance_types = [var.eks_node_instance_type]
      capacity_type  = "ON_DEMAND"

      min_size     = var.eks_node_group_min_size
      max_size     = var.eks_node_group_max_size
      desired_size = var.eks_node_group_desired_size

      # Use latest EKS optimized AMI
      ami_type = "AL2_x86_64"

      # Security group rules
      subnet_ids = module.vpc.private_subnets

      # Taints for system workloads
      taints = {}

      tags = local.common_tags
    }
  }

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  tags = local.common_tags
}

# ECR Repository Module
module "ecr" {
  source = "./modules/ecr"

  repository_names = var.ecr_repositories

  # Security configurations
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  # Lifecycle policy for cost optimization
  lifecycle_policy = {
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod", "production"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  }

  tags = local.common_tags
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  name_prefix = local.resource_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnets

  # Security configurations
  enable_waf      = true
  enable_logging  = true
  log_bucket_name = module.s3_logs.bucket_name
  certificate_arn = module.acm.certificate_arn

  # Health check configuration
  health_check = {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = local.common_tags
}

# RDS Module for application database
module "rds" {
  source = "./modules/rds"

  identifier = "${local.resource_prefix}-db"

  # Database configuration
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_encrypted     = true
  kms_key_id            = module.kms.rds_kms_key_arn

  # Network configuration
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.security_groups.rds_security_group_id]

  # Backup and maintenance
  backup_retention_period = var.environment == "production" ? 30 : 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Security configurations
  deletion_protection   = var.environment == "production"
  skip_final_snapshot   = var.environment != "production"
  copy_tags_to_snapshot = true

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval          = 60
  create_monitoring_role       = true

  tags = local.common_tags
}

# S3 Buckets Module
module "s3_logs" {
  source = "./modules/s3"

  bucket_name = "${local.resource_prefix}-logs-${local.random_suffix}"

  # Security configurations
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Encryption
  encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms.s3_kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  # Lifecycle management for cost optimization
  lifecycle_configuration = {
    rule = {
      id     = "log_lifecycle"
      status = "Enabled"

      expiration = {
        days = 90
      }

      noncurrent_version_expiration = {
        noncurrent_days = 30
      }
    }
  }

  # Versioning for data protection
  versioning = {
    enabled = true
  }

  tags = local.common_tags
}

# KMS Module for encryption
module "kms" {
  source = "./modules/kms"

  key_specs = {
    eks_cluster = {
      description = "EKS Cluster encryption key"
      usage       = "ENCRYPT_DECRYPT"
    }
    rds = {
      description = "RDS encryption key"
      usage       = "ENCRYPT_DECRYPT"
    }
    s3 = {
      description = "S3 bucket encryption key"
      usage       = "ENCRYPT_DECRYPT"
    }
    secrets = {
      description = "Secrets Manager encryption key"
      usage       = "ENCRYPT_DECRYPT"
    }
  }

  tags = local.common_tags
}

# ACM Certificate Module
module "acm" {
  source = "./modules/acm"

  domain_name = var.domain_name
  zone_id     = var.route53_zone_id

  tags = local.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"

  name_prefix = local.resource_prefix
  vpc_id      = module.vpc.vpc_id

  tags = local.common_tags
}

# CloudWatch Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  name_prefix = local.resource_prefix

  # EKS monitoring
  eks_cluster_name = module.eks.cluster_name

  # RDS monitoring
  rds_instance_identifier = module.rds.db_instance_identifier

  # ALB monitoring
  alb_arn_suffix = module.alb.alb_arn_suffix

  # SNS topic for alerts
  notification_email = var.notification_email

  tags = local.common_tags
}

# Secrets Manager for sensitive data
module "secrets" {
  source = "./modules/secrets"

  name_prefix = local.resource_prefix
  kms_key_id  = module.kms.secrets_kms_key_arn

  # Database credentials
  database_secrets = {
    username = var.db_username
    password = var.db_password
  }

  tags = local.common_tags
}