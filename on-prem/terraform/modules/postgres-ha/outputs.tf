# 공통 Terraform 모듈로, 반복되는 인프라 Provisioning 로직을 캡슐화해 운영 일관성을 높입니다.
# 모듈 입력값은 환경 특성(가용성/비용/보안)에 맞게 상위 environment에서 제어합니다.

output "contract" {
  description = "PostgreSQL HA 설계 계약 (구현은 Helm/Ansible/CNPG 등으로 연결)"
  value = {
    module                 = "postgres-ha"
    environment            = var.environment
    cluster_name           = var.cluster_name
    instance_count         = var.instance_count
    storage_size_gb        = var.storage_size_gb
    storage_class          = var.storage_class
    backup_retention_days  = var.backup_retention_days
    kubernetes_namespace   = var.kubernetes_namespace
    connection_pooling     = var.enable_connection_pooling
    implementation_note    = "Provision HA Postgres via CloudNativePG/Patroni or external cluster after Kubernetes workers exist."
  }
}
