# 공통 Terraform 모듈로, 반복되는 인프라 Provisioning 로직을 캡슐화해 운영 일관성을 높입니다.
# 모듈 입력값은 환경 특성(가용성/비용/보안)에 맞게 상위 environment에서 제어합니다.

output "worker_vm_ids" {
  description = "Created worker VM instance UUIDs"
  value       = vsphere_virtual_machine.k8s_worker[*].id
}

output "worker_vm_names" {
  description = "Created worker VM names"
  value       = vsphere_virtual_machine.k8s_worker[*].name
}
