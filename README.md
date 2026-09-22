# platform-infrastructure

Terraform for Gurujix AWS / shared cloud infrastructure (Phase 8).

> Git is the desired cloud state. Apply via reviewed PRs.  
> Do **not** commit `*.tfstate`, credentials, or `.terraform/`.

## Phase 8 roadmap (this repo)

| Slice | Focus |
| --- | --- |
| **8a** (this) | Repo layout + **remote state** bootstrap (S3 + DynamoDB lock) |
| **8b** | Network (VPC) |
| **8c** | EKS (or justified runtime) |
| **8d** | ECR + GitHub OIDC + IAM least privilege |
| **8e** | DNS/TLS for `platform.gurujix.com` / `app.gurujix.com` when ready |

## Layout

```text
bootstrap/     # One-time: create state bucket + lock table (local state)
live/
  ops/         # Day-2 root stack; uses remote backend after bootstrap
docs/          # Create / destroy / cost notes
```

## Prerequisites

- AWS account + IAM principal that can create S3/DynamoDB (bootstrap)
- Terraform `>= 1.5`
- `aws` CLI configured (`aws sts get-caller-identity` works)

Default region for learning: **`us-east-1`** (override with `TF_VAR_aws_region` / `*.tfvars`).

## 8a — Bootstrap remote state (DIY)

Chicken-and-egg: the backend must exist before other stacks can use it.

```sh
cd bootstrap
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

Copy outputs into `live/ops/backend.hcl` (see `backend.hcl.example`).

```sh
cd ../live/ops
cp backend.hcl.example backend.hcl   # fill bucket / dynamodb_table / region
terraform init -backend-config=backend.hcl
terraform plan
```

`live/ops` starts as a **smoke stack** (`aws_caller_identity` only) so you can prove remote state without spending on VPC/EKS yet.

## Cost guardrails

- Prefer **us-east-1** single-region learning footprint.
- Destroy nonessential stacks when idle (see `docs/destroy.md`).
- Enable billing alarms in the AWS console (or later Terraform) before EKS.
- Tag everything with `Project=gurujix` / `ManagedBy=terraform`.

## Safety

- Never commit real `backend.hcl` if it embeds account-specific secrets (bucket names are OK; no keys).
- Prefer GitHub **OIDC** later — no long-lived CI access keys in GitHub secrets.
- State bucket: versioning on, public access blocked (defined in `bootstrap/`).
