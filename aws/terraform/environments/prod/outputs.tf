# 환경별 인프라 진입점으로, 동일 모듈을 재사용하면서도 dev/stage/prod의 정책 차이를 변수로 분리합니다.
# 운영 시에는 변경 영향도를 계획(plan)으로 먼저 검증한 뒤 순차적으로 적용하는 것을 권장합니다.

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "Production VPC ID"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "Production EKS cluster name"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Production EKS API endpoint"
}
