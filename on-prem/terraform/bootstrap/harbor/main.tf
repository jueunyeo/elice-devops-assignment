terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.0"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kube_context
  }
}

locals {
  values_harbor_file = "${path.root}/../../environments/${var.environment}/addons/values-harbor.yaml"

  # Default operational overlays for HA and baseline resource controls.
  harbor_override_values = {
    persistence = {
      persistentVolumeClaim = {
        registry = {
          storageClass = var.storage_class_name
          size         = var.storage_size_registry
        }
        jobservice = {
          jobLog = {
            storageClass = var.storage_class_name
            size         = var.storage_size_jobservice
          }
        }
        database = {
          storageClass = var.storage_class_name
          size         = var.storage_size_database
        }
        redis = {
          storageClass = var.storage_class_name
          size         = var.storage_size_redis
        }
        trivy = {
          storageClass = var.storage_class_name
          size         = var.storage_size_trivy
        }
      }
    }

    expose = var.ingress_mode == "nginx" ? {
      type = "ingress"
      ingress = {
        hosts = {
          core = var.ingress_host
        }
        className = var.ingress_class_name
        annotations = {
          "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
          "nginx.ingress.kubernetes.io/proxy-read-timeout" = "600"
        }
      }
      tls = {
        enabled = true
      }
    } : {
      type = "clusterIP"
      tls = {
        enabled = true
      }
    }

    externalURL = "https://${var.ingress_host}"

    nginx = {
      replicas = 2
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "300m"
          memory = "256Mi"
        }
      }
    }

    portal = {
      replicas = 2
      resources = {
        requests = {
          cpu    = "200m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }

    core = {
      replicas = 2
      resources = {
        requests = {
          cpu    = "300m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
      }
    }

    jobservice = {
      replicas = 2
      resources = {
        requests = {
          cpu    = "200m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }

    registry = {
      replicas = 2
      resources = {
        requests = {
          cpu    = "500m"
          memory = "1Gi"
        }
        limits = {
          cpu    = "1"
          memory = "2Gi"
        }
      }
    }

    trivy = {
      enabled = true
      replicas = 2
      resources = {
        requests = {
          cpu    = "200m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "1Gi"
        }
      }
    }
  }
}

resource "kubernetes_namespace" "harbor" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "harbor" {
  name             = "harbor"
  repository       = "https://helm.goharbor.io"
  chart            = "harbor"
  version          = var.harbor_chart_version
  namespace        = kubernetes_namespace.harbor.metadata[0].name
  create_namespace = false

  values = [
    templatefile(local.values_harbor_file, {}),
    yamlencode(local.harbor_override_values)
  ]

  dynamic "set" {
    for_each = var.ingress_mode == "metallb" ? [1] : []
    content {
      name  = "service.type"
      value = var.harbor_service_type
    }
  }
}
