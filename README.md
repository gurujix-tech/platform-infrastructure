# platform-infrastructure

Terraform for Gurujix AWS / shared cloud infrastructure (Phase 8).

> Git is the desired cloud state. Apply via reviewed PRs.  
> Do **not** commit `*.tfstate`, credentials, or `.terraform/`.

**Milestone status / what’s next:**  
`gurujix-platform-engineering-master-plan.md` → *Current active milestone*.

## Layout

```text
bootstrap/     # One-time: state bucket (local state)
live/ops/      # Platform stack (remote S3 backend + use_lockfile)
docs/
  destroy.md   # Teardown command order only (not status)
```

## Prerequisites

- AWS account + IAM that can create S3 / EKS / IAM
- Terraform `>= 1.10`
- `aws` CLI (`aws sts get-caller-identity`)

Default learning region: **`us-east-1`**.

## Quick apply (after bootstrap exists)

```sh
cd live/ops
cp backend.hcl.example backend.hcl   # fill bucket / region; use_lockfile = true
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

First-time state bucket: `cd bootstrap && terraform init && terraform apply`, then wire `backend.hcl`.

## Teardown

See `docs/destroy.md`. Prefer deleting Ingress/ALB (Argo app) before `terraform destroy` so load balancers are not orphaned.

## Safety

- Never commit secrets or real credentials in `backend.hcl`.
- Prefer GitHub OIDC (no long-lived CI keys).
- Account budgets stay outside this destroyable stack.
