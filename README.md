# platform-infrastructure

Terraform for Gurujix AWS / shared cloud infrastructure (Phase 8).

> Git is the desired cloud state. Apply via reviewed PRs.  
> Do **not** commit `*.tfstate`, credentials, or `.terraform/`.

## Phase 8 roadmap (this repo)

| Slice | Focus |
| --- | --- |
| **8a** | Repo layout + **remote state** bootstrap (S3 + native lockfile) — done |
| **8b** | Network (VPC) — 2 AZ public/private, NAT optional — done |
| **8c** | EKS — small managed node group (public subnets, no NAT) — done |
| **8d** | ECR + GitHub OIDC + IAM least privilege — done |
| **8e** | DNS/TLS for `platform.gurujix.com` / `app.gurujix.com` — ACM via GoDaddy (Issued when DNS validates) |
| **Bridge** | Deploy `service-orders` to EKS from ECR (Helm; Argo on EKS later) |

## Layout

```text
bootstrap/     # One-time: create state bucket (local state)
live/
  ops/         # Day-2 root stack; uses remote S3 backend after bootstrap
docs/          # Create / destroy / cost notes
```

## Prerequisites

- AWS account + IAM principal that can create S3 (bootstrap)
- Terraform `>= 1.10` (for S3 `use_lockfile` native locking)
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
cp backend.hcl.example backend.hcl   # fill bucket / region; keep use_lockfile = true
terraform init -backend-config=backend.hcl
terraform plan
```

State locking uses **S3 native lockfiles** (`use_lockfile = true`) — no DynamoDB lock table.

## 8b — VPC (DIY)

After remote state works:

```sh
cd live/ops
terraform plan
terraform apply
terraform output
```

Creates a small **2-AZ** VPC (`10.42.0.0/16`) with public + private subnets and an IGW.  
**NAT Gateway is off by default** (hourly cost). Turn on when private workloads need egress:

```sh
terraform apply -var='enable_nat_gateway=true'
```

Details: `docs/vpc.md`.

## 8c — EKS (DIY)

**Cost:** EKS control plane ~$0.10/hr plus the node. Destroy or set `enable_eks=false` when idle.

```sh
cd live/ops
terraform plan
terraform apply
terraform output eks_configure_kubectl
# then: aws eks update-kubeconfig --region us-east-1 --name gurujix-platform
kubectl get nodes
```

Learning defaults: 1× `t3.medium` in **public** subnets (works with NAT off). Details: `docs/eks.md`.

## 8d — ECR + GitHub OIDC (DIY)

Creates a new role `gurujix-github-actions-ecr` + ECR repos. Reuses the existing account OIDC provider (data source). If ECR `service-orders` already exists, delete it first — see `docs/ecr-oidc.md`.

```sh
cd live/ops
terraform apply -var='enable_eks=false'
terraform output -raw github_actions_role_arn
```

Update **service-orders** secret `AWS_ROLE_ARN` to the new ARN.

## 8e — DNS / TLS (DIY)

Creates a Route53 zone for `gurujix.com` + ACM cert for `platform` / `app` (~$0.50/mo for the zone).

```sh
cd live/ops
terraform apply -var='enable_eks=false'
terraform output route53_name_servers
```

You must point the **registrar NS** at those servers (or validation stays pending). Details / hub-site caution: `docs/dns-tls.md`.

## Bridge — EKS deploy from ECR (DIY)

After ACM is Issued (optional for this step), run the app on EKS:

See `docs/eks-deploy.md` — Helm + `values-eks.yaml` + ECR image tag.

## Cost guardrails

- Prefer **us-east-1** single-region learning footprint.
- Leave `enable_nat_gateway=false` until you need it; destroy EKS when idle (`docs/destroy.md` / `enable_eks=false`).
- Enable billing alarms in the AWS console before leaving clusters running overnight.
- Tag everything with `Project=gurujix` / `ManagedBy=terraform`.

## Safety

- Never commit real `backend.hcl` if it embeds account-specific secrets (bucket names are OK; no keys).
- Prefer GitHub **OIDC** later — no long-lived CI access keys in GitHub secrets.
- State bucket: versioning on, public access blocked (defined in `bootstrap/`).
