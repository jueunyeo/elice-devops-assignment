# 공통 Terraform 모듈로, 반복되는 인프라 Provisioning 로직을 캡슐화해 운영 일관성을 높입니다.
# 모듈 입력값은 환경 특성(가용성/비용/보안)에 맞게 상위 environment에서 제어합니다.

variable "environment" {
  description = "Logical environment name (dev, stage, prod)"
  type        = string
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
  description = "Template VM name for cloning workers"
  type        = string
}

variable "worker_count" {
  description = "Number of Kubernetes worker VMs"
  type        = number
}

variable "vm_num_cpus" {
  description = "vCPUs per worker"
  type        = number
}

variable "vm_memory_mb" {
  description = "Memory in MB per worker"
  type        = number
}

variable "vm_disk_gb" {
  description = "OS disk size in GB per worker"
  type        = number
}

variable "tags" {
  description = "Optional extra_config tags (string map)"
  type        = map(string)
  default     = {}
}
