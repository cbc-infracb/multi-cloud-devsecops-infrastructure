# Multi-Cloud DevSecOps Infrastructure

This repository contains Terraform infrastructure-as-code implementations for deploying a comprehensive DevSecOps architecture on both Microsoft Azure and Amazon Web Services (AWS). Both implementations follow their respective Well-Architected Framework principles and incorporate security best practices throughout.

## 🏗️ Architecture Overview

### Key Features
- **Container-native** Kubernetes clusters (AKS/EKS) with auto-scaling
- **Zero-trust security** with private endpoints and network isolation
- **Comprehensive monitoring** with native cloud observability tools
- **Security-first approach** with vulnerability scanning and threat detection
- **Cost-optimized** resource configurations with auto-scaling capabilities

### Azure Architecture Components
- Virtual Network with private subnets and Network Security Groups
- Azure Kubernetes Service (AKS) with managed node pools
- Azure Container Registry (ACR) with Premium security features
- Azure Key Vault with private endpoint access
- Application Gateway with Web Application Firewall (WAF)
- Azure Monitor, Application Insights, and Log Analytics
- Microsoft Defender for Containers and Azure Sentinel integration

### AWS Architecture Components
- VPC with multi-AZ private/public subnet design
- Amazon Elastic Kubernetes Service (EKS) with managed node groups
- Amazon Elastic Container Registry (ECR) with vulnerability scanning
- AWS Secrets Manager with KMS encryption
- Application Load Balancer with AWS WAF
- Amazon RDS PostgreSQL with Multi-AZ deployment
- CloudWatch for comprehensive monitoring and logging

## 🚀 Quick Start

### Prerequisites
- [Terraform](https://terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for Azure deployment)
- [AWS CLI](https://aws.amazon.com/cli/) (for AWS deployment)
- Appropriate cloud provider credentials configured

### Azure Deployment

```bash
cd azure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
terraform init
terraform plan
terraform apply
```

### AWS Deployment

```bash
cd aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
terraform init
terraform plan
terraform apply
```

## 📊 Cost Analysis

| Cloud Provider | Monthly Estimate | Key Cost Drivers |
|----------------|------------------|------------------|
| **Azure** | ~$1,067 | Application Gateway WAF, Premium ACR, VM costs |
| **AWS** | ~$655 | EKS control plane, EC2 instances, RDS Multi-AZ |

**AWS offers 38% cost savings** primarily due to lower compute and networking costs. See [COST_ANALYSIS.md](COST_ANALYSIS.md) for detailed breakdown and optimization strategies.

## 🔐 Security Features

### Azure Security
- Private endpoints for all Azure PaaS services
- Azure Key Vault for secrets management
- Microsoft Defender for Containers
- Azure Sentinel for SIEM capabilities
- Network Security Groups for micro-segmentation
- Azure Policy for governance and compliance

### AWS Security
- VPC with private subnets and security groups
- AWS Secrets Manager with KMS encryption
- Amazon GuardDuty for threat detection
- AWS Security Hub for centralized security posture
- IAM roles with least-privilege principles
- VPC Flow Logs for network monitoring

## 📁 Repository Structure

```
├── azure/                          # Azure implementation
│   ├── main.tf                     # Main configuration
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values
│   ├── terraform.tfvars.example    # Example variables
│   └── modules/                    # Azure-specific modules
│       ├── network/                # Virtual Network & subnets
│       ├── aks/                    # Azure Kubernetes Service
│       ├── container_registry/     # Azure Container Registry
│       ├── key_vault/              # Azure Key Vault
│       ├── application_gateway/    # Application Gateway + WAF
│       ├── monitoring/             # Azure Monitor & insights
│       └── security/               # Defender & Sentinel
├── aws/                            # AWS implementation
│   ├── main.tf                     # Main configuration
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values
│   ├── terraform.tfvars.example    # Example variables
│   └── modules/                    # AWS-specific modules
│       ├── vpc/                    # VPC & networking
│       ├── eks/                    # Elastic Kubernetes Service
│       ├── ecr/                    # Elastic Container Registry
│       ├── rds/                    # RDS PostgreSQL
│       ├── alb/                    # Application Load Balancer
│       ├── kms/                    # Key Management Service
│       ├── monitoring/             # CloudWatch & alerting
│       └── security_groups/        # Security group definitions
├── COST_ANALYSIS.md                # Detailed cost comparison
└── README.md                       # This file
```

## 🎯 Well-Architected Principles

Both implementations follow cloud provider best practices:

### Azure Well-Architected Framework
- ✅ **Cost Optimization**: Reserved instances, auto-scaling, resource monitoring
- ✅ **Security**: Zero-trust networking, identity-based access control
- ✅ **Reliability**: Multi-zone deployment, automated backup strategies
- ✅ **Performance**: Application Gateway optimization, container rightsizing
- ✅ **Operational Excellence**: Infrastructure as Code, comprehensive monitoring

### AWS Well-Architected Framework
- ✅ **Cost Optimization**: Spot instances, savings plans, automated rightsizing
- ✅ **Security**: Defense in depth, encryption everywhere, IAM best practices
- ✅ **Reliability**: Multi-AZ deployment, auto-recovery mechanisms
- ✅ **Performance**: Load balancer optimization, performance monitoring
- ✅ **Operational Excellence**: Automated deployment, comprehensive logging

## 🔧 Customization

### Environment Configuration
Both implementations support multiple environments (dev, staging, prod) with different:
- Resource sizing (node counts, instance types)
- Security configurations (private endpoints, encryption)
- Monitoring and retention policies
- Cost optimization settings

### Variable Customization
Key variables you should customize in `terraform.tfvars`:

**Azure:**
```hcl
environment = "dev"                    # or "staging", "prod"
location = "East US"                   # Azure region
aks_default_node_pool_vm_size = "Standard_D2s_v3"
enable_sentinel = false                # Enable for production
```

**AWS:**
```hcl
environment = "dev"                    # or "staging", "prod"
aws_region = "us-east-1"              # AWS region
eks_node_instance_type = "t3.medium"
notification_email = "admin@company.com"
```

## 📈 Monitoring & Observability

### Azure Monitoring Stack
- **Azure Monitor**: Centralized monitoring platform
- **Application Insights**: Application performance monitoring
- **Log Analytics**: Centralized log collection and analysis
- **Azure Sentinel**: Security information and event management

### AWS Monitoring Stack
- **CloudWatch**: Metrics, logs, and alarms
- **AWS X-Ray**: Application tracing and debugging
- **GuardDuty**: Intelligent threat detection
- **CloudTrail**: API call logging and auditing

## 🚨 Security Considerations

### Before Deployment
1. Review and customize security groups/NSGs
2. Configure appropriate RBAC/IAM policies
3. Enable encryption for all data at rest and in transit
4. Set up monitoring alerts for security events
5. Implement backup and disaster recovery strategies

### Post-Deployment
1. Regularly update Kubernetes versions
2. Monitor container vulnerability scans
3. Review access logs and security alerts
4. Perform security assessments and penetration testing
5. Maintain compliance with industry standards

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes following the established patterns
4. Test your changes with `terraform plan`
5. Submit a pull request with detailed description

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions or issues:
1. Check the [Issues](../../issues) page for existing discussions
2. Create a new issue with detailed description and error messages
3. Include relevant configuration files (sanitized)

---

**Note**: These configurations are production-ready templates but should be customized based on your specific requirements, compliance needs, and security policies. Always perform thorough testing in non-production environments before deploying to production.