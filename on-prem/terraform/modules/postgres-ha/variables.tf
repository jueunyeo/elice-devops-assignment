# 공통 Terraform 모듈로, 반복되는 인프라 Provisioning 로직을 캡슐화해 운영 일관성을 높입니다.
# 모듈 입력값은 환경 특성(가용성/비용/보안)에 맞게 상위 environment에서 제어합니다.

# ---------------------------------------------------------------------------
# PostgreSQL HA (온프레) — 구현 계약(Interface)
# 실제 프로비저닝은 CloudNativePG, Patroni, 또는 외부 클러스터 + Ansible/Helm로 수행.
# 이 variables 블록은 AWS RDS Multi-AZ와의 1:1 설계 대화를 위한 입력 스키마입니다.
# ---------------------------------------------------------------------------

variable "environment" {
  description = "Environment (dev, stage, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Logical PostgreSQL cluster name"
  type        = string
}

variable "instance_count" {
  description = "Primary + replica count (HA: >= 3 권장)"
  type        = number
  default     = 3
}

variable "storage_size_gb" {
  description = "Per-instance persistent volume size (GiB)"
  type        = number
  default     = 100
}

variable "storage_class" {
  description = "Kubernetes StorageClass for data volumes"
  type        = string
  default     = "fast-ssd"
}

variable "backup_retention_days" {
  description = "Point-in-time / logical backup retention"
  type        = number
  default     = 14
}

variable "kubernetes_namespace" {
  description = "Namespace for PostgreSQL operator workload"
  type        = string
  default     = "datastore"
}

variable "enable_connection_pooling" {
  description = "Whether to deploy PgBouncer or equivalent (boolean contract)"
  type        = bool
  default     = true
}
