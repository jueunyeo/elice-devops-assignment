variable "environment" {
  description = "Target environment name (dev, stage, prod)."
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig for on-prem Kubernetes cluster."
  type        = string
}

variable "kube_context" {
  description = "Optional kube context for target cluster."
  type        = string
  default     = null
}

variable "namespace" {
  description = "Namespace where Harbor is deployed."
  type        = string
  default     = "harbor"
}

variable "harbor_chart_version" {
  description = "Helm chart version for Harbor."
  type        = string
  default     = "1.15.0"
}

variable "storage_class_name" {
  description = "Existing storage class name used by Harbor PVCs."
  type        = string
}

variable "storage_size_registry" {
  description = "Registry PVC size."
  type        = string
  default     = "100Gi"
}

variable "storage_size_jobservice" {
  description = "Jobservice PVC size."
  type        = string
  default     = "20Gi"
}

variable "storage_size_database" {
  description = "Database PVC size."
  type        = string
  default     = "20Gi"
}

variable "storage_size_redis" {
  description = "Redis PVC size."
  type        = string
  default     = "10Gi"
}

variable "storage_size_trivy" {
  description = "Trivy PVC size."
  type        = string
  default     = "10Gi"
}

variable "ingress_mode" {
  description = "Ingress mode for Harbor. Use nginx or metallb."
  type        = string
  default     = "nginx"

  validation {
    condition     = contains(["nginx", "metallb"], var.ingress_mode)
    error_message = "ingress_mode must be either nginx or metallb."
  }
}

variable "ingress_host" {
  description = "Harbor ingress host."
  type        = string
}

variable "ingress_class_name" {
  description = "IngressClassName for NGINX mode."
  type        = string
  default     = "nginx"
}

variable "harbor_service_type" {
  description = "Service type when ingress_mode is metallb (NodePort or LoadBalancer)."
  type        = string
  default     = "LoadBalancer"
}
