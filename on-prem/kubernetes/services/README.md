# On-Prem Service Manifest Contract

This repository is an infrastructure and GitOps target repository.

- Application source code is managed in separate app repositories.
- This folder keeps deploy-only manifests consumed by ArgoCD.
- External CI should only update image tags in:
  - `on-prem/kubernetes/services/<service>/values-dev.yaml`
  - `on-prem/kubernetes/services/<service>/values-stage.yaml`
  - `on-prem/kubernetes/services/<service>/values-prod.yaml`

## Update rule

Update only `image.tag` for each environment file. Avoid changing shared runtime policies unless explicitly approved by platform owners.
