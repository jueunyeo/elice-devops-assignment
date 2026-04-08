output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN."
  value       = try(aws_iam_openid_connect_provider.github[0].arn, null)
}

output "management_role_arn" {
  description = "GitHub Actions entry role ARN in management account."
  value       = try(aws_iam_role.github_actions_management[0].arn, null)
}

output "target_role_arn" {
  description = "Terraform deploy role ARN in child account."
  value       = try(aws_iam_role.terraform_deploy_target[0].arn, null)
}

output "atlantis_irsa_role_arn" {
  description = "Atlantis IRSA role ARN."
  value       = try(aws_iam_role.atlantis_irsa[0].arn, null)
}
