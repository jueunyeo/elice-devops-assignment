# 환경별 인프라 진입점으로, 동일 모듈을 재사용하면서도 dev/stage/prod의 정책 차이를 변수로 분리합니다.
# 운영 시에는 변경 영향도를 계획(plan)으로 먼저 검증한 뒤 순차적으로 적용하는 것을 권장합니다.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.6.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# Prod: 고가용성 워커 풀.
module "k8s_workers" {
  source = "../../modules/vsphere-k8s-worker"

  environment     = var.environment
  datacenter_name = var.datacenter_name
  datastore_name  = var.datastore_name
  cluster_name    = var.cluster_name
  network_name    = var.network_name
  template_name   = var.template_name
  worker_count    = var.worker_count
  vm_num_cpus     = var.vm_num_cpus
  vm_memory_mb    = var.vm_memory_mb
  vm_disk_gb      = var.vm_disk_gb
}

module "postgres_ha_contract" {
  source = "../../modules/postgres-ha"

  environment               = var.environment
  cluster_name              = "elice-${var.environment}-postgres"
  instance_count            = 3
  storage_size_gb           = 200
  backup_retention_days     = 14
  kubernetes_namespace      = "datastore-${var.environment}"
  enable_connection_pooling = true
}
