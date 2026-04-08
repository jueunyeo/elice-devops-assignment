data "aws_caller_identity" "current" {}

locals {
  repo_subject_patterns = [
    for ref in var.allowed_refs : "repo:${var.github_org}/${var.github_repo}:ref:${ref}"
  ]

  computed_management_role_arn = var.management_role_arn != null ? var.management_role_arn : (
    var.management_account_id != null ? "arn:aws:iam::${var.management_account_id}:role/${var.management_role_name}" : null
  )
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = [var.github_oidc_audience]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_oidc_trust" {
  count = var.create_management_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [var.github_oidc_audience]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.repo_subject_patterns
    }
  }
}

resource "aws_iam_role" "github_actions_management" {
  count = var.create_management_role ? 1 : 0

  name               = var.management_role_name
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust[0].json
}

data "aws_iam_policy_document" "management_assume_targets" {
  count = var.create_management_role && length(var.target_assume_role_arns) > 0 ? 1 : 0

  statement {
    sid     = "AssumeChildDeployRoles"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = var.target_assume_role_arns
  }
}

resource "aws_iam_role_policy" "management_assume_targets" {
  count = var.create_management_role && length(var.target_assume_role_arns) > 0 ? 1 : 0

  name   = "AssumeChildDeployRoles"
  role   = aws_iam_role.github_actions_management[0].id
  policy = data.aws_iam_policy_document.management_assume_targets[0].json
}

data "aws_iam_policy_document" "target_trust_management" {
  count = var.create_target_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.computed_management_role_arn]
    }
  }
}

resource "aws_iam_role" "terraform_deploy_target" {
  count = var.create_target_role ? 1 : 0

  name               = var.target_role_name
  assume_role_policy = data.aws_iam_policy_document.target_trust_management[0].json

  lifecycle {
    precondition {
      condition     = local.computed_management_role_arn != null
      error_message = "management_role_arn or management_account_id must be set when create_target_role=true."
    }
  }
}

resource "aws_iam_role_policy_attachment" "target_admin_access" {
  count = var.create_target_role && var.target_role_policy_json == null ? 1 : 0

  role       = aws_iam_role.terraform_deploy_target[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy" "target_custom" {
  count = var.create_target_role && var.target_role_policy_json != null ? 1 : 0

  name   = "TerraformDeployCustomPolicy"
  role   = aws_iam_role.terraform_deploy_target[0].id
  policy = var.target_role_policy_json
}
