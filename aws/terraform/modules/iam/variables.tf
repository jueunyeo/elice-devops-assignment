variable "github_org" {
  description = "GitHub organization (or user) that owns the repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "github_oidc_audience" {
  description = "Audience used in GitHub OIDC token."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "allowed_refs" {
  description = "Allowed Git refs (for example refs/heads/main or refs/tags/v*)."
  type        = list(string)
  default     = ["refs/heads/main"]
}

variable "create_oidc_provider" {
  description = "Whether to create GitHub OIDC provider in this account."
  type        = bool
  default     = true
}

variable "create_management_role" {
  description = "Whether to create management account entry role for GitHub Actions."
  type        = bool
  default     = true
}

variable "management_role_name" {
  description = "Role name used by GitHub Actions in management account."
  type        = string
  default     = "GitHubActionsManagementRole"
}

variable "target_assume_role_arns" {
  description = "Role ARNs in child accounts that the management role can assume."
  type        = list(string)
  default     = []
}

variable "create_target_role" {
  description = "Whether to create deploy role in this account trusted by management role."
  type        = bool
  default     = false
}

variable "target_role_name" {
  description = "Deploy role name in child account."
  type        = string
  default     = "TerraformDeployRole"
}

variable "management_account_id" {
  description = "Management account ID that hosts the GitHub Actions entry role."
  type        = string
  default     = null
}

variable "management_role_arn" {
  description = "Optional explicit management role ARN. If set, overrides management_account_id + management_role_name."
  type        = string
  default     = null
}

variable "target_role_policy_json" {
  description = "Optional inline policy JSON to attach to target role."
  type        = string
  default     = null
}

variable "create_atlantis_irsa_role" {
  description = "Whether to create IRSA role for Atlantis service account."
  type        = bool
  default     = false
}

variable "atlantis_irsa_role_name" {
  description = "IAM role name for Atlantis IRSA."
  type        = string
  default     = "AtlantisAssumeRole"
}

variable "eks_oidc_provider_arn" {
  description = "OIDC provider ARN of EKS cluster running Atlantis."
  type        = string
  default     = null
}

variable "eks_oidc_provider_url" {
  description = "OIDC issuer URL of EKS cluster running Atlantis (without https://)."
  type        = string
  default     = null
}

variable "atlantis_namespace" {
  description = "Kubernetes namespace where Atlantis service account exists."
  type        = string
  default     = "atlantis"
}

variable "atlantis_service_account_name" {
  description = "Kubernetes service account name used by Atlantis."
  type        = string
  default     = "atlantis"
}

variable "atlantis_target_assume_role_arns" {
  description = "Target role ARNs Atlantis IRSA role can assume."
  type        = list(string)
  default     = []
}
