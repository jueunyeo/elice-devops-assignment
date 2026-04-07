# 환경별 인프라 진입점으로, 동일 모듈을 재사용하면서도 dev/stage/prod의 정책 차이를 변수로 분리합니다.
# 운영 시에는 변경 영향도를 계획(plan)으로 먼저 검증한 뒤 순차적으로 적용하는 것을 권장합니다.

variable "vsphere_server" {
  description = "vSphere endpoint URL or hostname"
  type        = string
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "datacenter_name" {
  description = "vSphere datacenter name"
  type        = string
}

variable "datastore_name" {
  description = "vSphere datastore name"
  type        = string
}

variable "cluster_name" {
  description = "vSphere cluster name"
  type        = string
}

variable "network_name" {
  description = "vSphere network name"
  type        = string
}

variable "template_name" {
  description = "Template VM name for cloning worker nodes"
  type        = string
}

variable "environment" {
  description = "Logical environment (dev)"
  type        = string
  default     = "dev"
}

variable "worker_count" {
  description = "K8s worker VM count (Dev: minimal)"
  type        = number
  default     = 1
}

variable "vm_num_cpus" {
  description = "vCPUs per worker"
  type        = number
  default     = 2
}

variable "vm_memory_mb" {
  description = "Memory MB per worker"
  type        = number
  default     = 4096
}

variable "vm_disk_gb" {
  description = "OS disk size GB per worker"
  type        = number
  default     = 80
}
