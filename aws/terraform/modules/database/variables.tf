# 공통 Terraform 모듈로, 반복되는 인프라 Provisioning 로직을 캡슐화해 운영 일관성을 높입니다.
# 모듈 입력값은 환경 특성(가용성/비용/보안)에 맞게 상위 environment에서 제어합니다.

variable "identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.3"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID for RDS security group"
  type        = string
}

variable "subnet_ids" {
  description = "Database subnet IDs"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access PostgreSQL"
  type        = list(string)
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Common tags applied to resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_deletion_window_in_days" {
  description = "KMS key deletion window for RDS encryption key."
  type        = number
  default     = 30
}
