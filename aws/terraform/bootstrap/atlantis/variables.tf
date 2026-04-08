variable "aws_region" {
  description = "AWS region where EKS cluster and Atlantis are deployed."
  type        = string
  default     = "ap-northeast-2"
}

variable "project" {
  description = "Project prefix for naming."
  type        = string
  default     = "elice"
}

variable "environment" {
  description = "Bootstrap environment label."
  type        = string
  default     = "management"
}

variable "eks_cluster_name" {
  description = "EKS cluster name where Atlantis will be installed."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Namespace for Atlantis deployment."
  type        = string
  default     = "atlantis"
}

variable "service_account_name" {
  description = "Kubernetes service account name used by Atlantis."
  type        = string
  default     = "atlantis"
}

variable "atlantis_chart_version" {
  description = "Helm chart version of runatlantis/atlantis."
  type        = string
  default     = "5.16.0"
}

variable "atlantis_repo_allowlist" {
  description = "Atlantis repo allowlist."
  type        = string
}

variable "github_secret_id" {
  description = "Secrets Manager secret id/arn containing Atlantis GitHub credentials JSON."
  type        = string
}

variable "github_token_key" {
  description = "JSON key for GitHub token in Secrets Manager secret."
  type        = string
  default     = "github_token"
}

variable "github_webhook_secret_key" {
  description = "JSON key for GitHub webhook secret in Secrets Manager secret."
  type        = string
  default     = "webhook_secret"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for Atlantis ALB HTTPS listener."
  type        = string
}

variable "atlantis_hostname" {
  description = "Public DNS hostname for Atlantis (for example atlantis.example.com)."
  type        = string
}

variable "target_assume_role_arns" {
  description = "Role ARNs Atlantis can assume for multi-account Terraform."
  type        = list(string)
}

variable "atlantis_replica_count" {
  description = "Atlantis replica count for HA."
  type        = number
  default     = 2
}

variable "atlantis_cpu_request" {
  description = "Atlantis CPU request."
  type        = string
  default     = "500m"
}

variable "atlantis_memory_request" {
  description = "Atlantis memory request."
  type        = string
  default     = "512Mi"
}

variable "atlantis_cpu_limit" {
  description = "Atlantis CPU limit."
  type        = string
  default     = "1"
}

variable "atlantis_memory_limit" {
  description = "Atlantis memory limit."
  type        = string
  default     = "1Gi"
}
