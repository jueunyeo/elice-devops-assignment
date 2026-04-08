output "harbor_namespace" {
  description = "Namespace where Harbor is deployed."
  value       = kubernetes_namespace.harbor.metadata[0].name
}

output "harbor_release_name" {
  description = "Helm release name for Harbor."
  value       = helm_release.harbor.name
}

output "harbor_values_file" {
  description = "Environment values file used for Harbor bootstrap."
  value       = local.values_harbor_file
}
