# IAM module for multi-account delivery

This module supports two deployment modes.

## 1) GitHub OIDC management bootstrap

- Creates GitHub OIDC provider
- Creates management entry role for GitHub Actions
- Grants `sts:AssumeRole` to target account deploy roles

## 2) Child account deploy role bootstrap

- Creates deploy role trusted by management entry role
- By default attaches `AdministratorAccess` (replace with custom policy when hardening)

## 3) Atlantis IRSA bootstrap

- Creates IAM role trusted by EKS OIDC provider (`sts:AssumeRoleWithWebIdentity`)
- Restricts trust to `system:serviceaccount:<namespace>:<serviceaccount>`
- Grants `sts:AssumeRole` to each environment account role

## Example (management account)

```hcl
module "gha_iam_management" {
  source = "../../modules/iam"

  github_org  = "your-org"
  github_repo = "elice-devops-assignment"

  create_oidc_provider   = true
  create_management_role = true
  management_role_name   = "GitHubActionsManagementRole"

  target_assume_role_arns = [
    "arn:aws:iam::111111111111:role/OrganizationAccountAccessRole",
    "arn:aws:iam::222222222222:role/OrganizationAccountAccessRole",
    "arn:aws:iam::333333333333:role/OrganizationAccountAccessRole"
  ]

  allowed_refs = [
    "refs/heads/main",
    "refs/pull/*/merge"
  ]
}
```

## Example (child account)

```hcl
module "gha_iam_target" {
  source = "../../modules/iam"

  github_org  = "your-org"
  github_repo = "elice-devops-assignment"

  create_oidc_provider   = false
  create_management_role = false

  create_target_role    = true
  target_role_name      = "TerraformDeployRole"
  management_account_id = "123456789012"
  management_role_name  = "GitHubActionsManagementRole"
}
```

## Example (Atlantis IRSA role in management account)

```hcl
module "atlantis_iam" {
  source = "../../modules/iam"

  github_org  = "unused"
  github_repo = "unused"

  create_oidc_provider   = false
  create_management_role = false
  create_target_role     = false

  create_atlantis_irsa_role    = true
  atlantis_irsa_role_name      = "AtlantisAssumeRole"
  eks_oidc_provider_arn        = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/EXAMPLE"
  eks_oidc_provider_url        = "https://oidc.eks.ap-northeast-2.amazonaws.com/id/EXAMPLE"
  atlantis_namespace           = "atlantis"
  atlantis_service_account_name = "atlantis"

  atlantis_target_assume_role_arns = [
    "arn:aws:iam::111111111111:role/OrganizationAccountAccessRole",
    "arn:aws:iam::222222222222:role/OrganizationAccountAccessRole",
    "arn:aws:iam::333333333333:role/OrganizationAccountAccessRole"
  ]
}
```
