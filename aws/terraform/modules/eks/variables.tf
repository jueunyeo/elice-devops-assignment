# 공통 Terraform 모듈로, 반복되는 인프라 Provisioning 로직을 캡슐화해 운영 일관성을 높입니다.
# 모듈 입력값은 환경 특성(가용성/비용/보안)에 맞게 상위 environment에서 제어합니다.

variable "name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "vpc_id" {
  description = "VPC ID for EKS resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for EKS control plane and nodes"
  type        = list(string)
}

variable "node_group_name" {
  description = "Managed node group name"
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "tags" {
  description = "Common tags applied to resources"
  type        = map(string)
  default     = {}
}

variable "enable_irsa_for_eso" {
  description = "Create IAM role for External Secrets Operator using IRSA"
  type        = bool
  default     = true
}

variable "eso_namespace" {
  description = "Namespace where external-secrets service account is running"
  type        = string
  default     = "external-secrets"
}

variable "eso_service_account_name" {
  description = "Service account name for external-secrets controller"
  type        = string
  default     = "external-secrets"
}

variable "eso_allowed_secret_arns" {
  description = "Allowed AWS Secrets Manager ARNs for ESO read access"
  type        = list(string)
  default     = ["*"]
}
