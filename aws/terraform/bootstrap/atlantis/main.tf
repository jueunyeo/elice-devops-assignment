terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
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

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_secretsmanager_secret_version" "github" {
  secret_id = var.github_secret_id
}

locals {
  github_secret = jsondecode(data.aws_secretsmanager_secret_version.github.secret_string)

  irsa_role_name = "${var.project}-${var.environment}-atlantis-irsa"
}

data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.kubernetes_namespace}:${var.service_account_name}"]
    }
  }
}

resource "aws_iam_role" "atlantis_irsa" {
  name               = local.irsa_role_name
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

data "aws_iam_policy_document" "atlantis_assume_targets" {
  statement {
    sid       = "AssumeOrganizationAccounts"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = var.target_assume_role_arns
  }
}

resource "aws_iam_role_policy" "atlantis_assume_targets" {
  name   = "${local.irsa_role_name}-assume-targets"
  role   = aws_iam_role.atlantis_irsa.id
  policy = data.aws_iam_policy_document.atlantis_assume_targets.json
}

resource "kubernetes_namespace" "atlantis" {
  metadata {
    name = var.kubernetes_namespace
  }
}

resource "kubernetes_service_account" "atlantis" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace.atlantis.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.atlantis_irsa.arn
    }
  }

  automount_service_account_token = true
}

resource "helm_release" "atlantis" {
  name       = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"
  version    = var.atlantis_chart_version
  namespace  = kubernetes_namespace.atlantis.metadata[0].name

  values = [
    yamlencode({
      orgAllowlist = var.atlantis_repo_allowlist
      replicaCount = var.atlantis_replica_count

      serviceAccount = {
        create = false
        name   = kubernetes_service_account.atlantis.metadata[0].name
      }

      resources = {
        requests = {
          cpu    = var.atlantis_cpu_request
          memory = var.atlantis_memory_request
        }
        limits = {
          cpu    = var.atlantis_cpu_limit
          memory = var.atlantis_memory_limit
        }
      }

      ingress = {
        enabled          = true
        ingressClassName = "alb"
        host             = var.atlantis_hostname
        path             = "/*"
        pathType         = "ImplementationSpecific"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"              = "ip"
          "alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTPS\":443}]"
          "alb.ingress.kubernetes.io/certificate-arn"          = var.acm_certificate_arn
          "alb.ingress.kubernetes.io/ssl-policy"               = "ELBSecurityPolicy-TLS13-1-2-2021-06"
          "alb.ingress.kubernetes.io/ssl-redirect"             = "443"
          "alb.ingress.kubernetes.io/healthcheck-path"         = "/healthz"
          "alb.ingress.kubernetes.io/load-balancer-attributes" = "routing.http.drop_invalid_header_fields.enabled=true"
        }
      }
    })
  ]

  set_sensitive {
    name  = "github.token"
    value = local.github_secret[var.github_token_key]
  }

  set_sensitive {
    name  = "github.secret"
    value = local.github_secret[var.github_webhook_secret_key]
  }

  depends_on = [kubernetes_service_account.atlantis]
}
