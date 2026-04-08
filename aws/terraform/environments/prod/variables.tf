# 환경별 인프라 진입점으로, 동일 모듈을 재사용하면서도 dev/stage/prod의 정책 차이를 변수로 분리합니다.
# 운영 시에는 변경 영향도를 계획(plan)으로 먼저 검증한 뒤 순차적으로 적용하는 것을 권장합니다.

variable "aws_region" {
  description = "AWS region for production"
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_account_id" {
  description = "AWS account ID for production environment"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR for production"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Three AZs for HA"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs for production"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for production"
  type        = list(string)
  default     = ["10.0.64.0/20", "10.0.80.0/20", "10.0.96.0/20"]
}

variable "database_subnet_cidrs" {
  description = "Database subnet CIDRs for production"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
}

variable "single_nat_gateway" {
  description = "Disable single NAT in production to avoid egress SPOF"
  type        = bool
  default     = false
}

variable "eks_instance_types" {
  description = "EKS node group instance types"
  type        = list(string)
  default     = ["m6i.large"]
}

variable "eks_desired_size" {
  description = "Desired EKS worker nodes"
  type        = number
  default     = 6
}

variable "eks_min_size" {
  description = "Minimum EKS worker nodes"
  type        = number
  default     = 3
}

variable "eks_max_size" {
  description = "Maximum EKS worker nodes"
  type        = number
  default     = 12
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "elicedb"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.m6g.large"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GiB"
  type        = number
  default     = 200
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 14
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for production database"
  type        = bool
  default     = true
}

variable "storage_force_destroy" {
  description = "Allow bucket destroy in production"
  type        = bool
  default     = false
}

variable "eso_allowed_secret_arns" {
  description = "Secrets Manager ARNs accessible by ESO IRSA role"
  type        = list(string)
  default     = ["*"]
}
