# IAM module for GitHub OIDC multi-account delivery

This module supports two deployment modes.

## 1) Management account bootstrap

- Creates GitHub OIDC provider
- Creates management entry role for GitHub Actions
- Grants `sts:AssumeRole` to target account deploy roles

## 2) Child account deploy role bootstrap

- Creates deploy role trusted by management entry role
- By default attaches `AdministratorAccess` (replace with custom policy when hardening)

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
