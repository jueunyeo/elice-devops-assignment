output "atlantis_namespace" {
  description = "Kubernetes namespace where Atlantis is deployed."
  value       = kubernetes_namespace.atlantis.metadata[0].name
}

output "atlantis_service_account_name" {
  description = "Atlantis service account name."
  value       = kubernetes_service_account.atlantis.metadata[0].name
}

output "atlantis_irsa_role_arn" {
  description = "IAM role ARN used by Atlantis via IRSA."
  value       = aws_iam_role.atlantis_irsa.arn
}

output "atlantis_release_name" {
  description = "Helm release name for Atlantis."
  value       = helm_release.atlantis.name
}
