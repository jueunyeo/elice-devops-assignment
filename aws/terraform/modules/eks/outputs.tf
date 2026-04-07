# 공통 Terraform 모듈로, 반복되는 인프라 Provisioning 로직을 캡슐화해 운영 일관성을 높입니다.
# 모듈 입력값은 환경 특성(가용성/비용/보안)에 맞게 상위 environment에서 제어합니다.

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "EKS cluster security group"
  value       = aws_security_group.cluster.id
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN used for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "eso_irsa_role_arn" {
  description = "IAM role ARN for external-secrets via IRSA"
  value       = var.enable_irsa_for_eso ? aws_iam_role.eso_irsa[0].arn : null
}
