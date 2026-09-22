# Phase 8d — ECR + GitHub OIDC

Creates a **new** IAM role + ECR repos. GitHub OIDC provider: one per account.

| Situation | Flag |
| --- | --- |
| Provider already exists (this account) | default `create_github_oidc_provider=false` — data lookup |
| Brand-new account, no provider yet | `-var='create_github_oidc_provider=true'` |

## Before apply (clean slate for ECR)

ECR name `service-orders` is already taken by the Phase 4 repo. Delete it if you want Terraform to recreate it:

```sh
aws ecr delete-repository --repository-name service-orders --region us-east-1 --force
```

(Optional) remove the old role when GitHub points at the new one:

```sh
aws iam delete-role-policy --role-name github-ecr-service-orders --policy-name ecr-push-service-orders
aws iam delete-role --role-name github-ecr-service-orders
```

## Apply

```sh
cd live/ops
terraform init
terraform apply -var='enable_eks=false'
terraform output -raw github_actions_role_arn
terraform output ecr_repository_urls
```

## Update GitHub (`service-orders`)

1. Secret `AWS_ROLE_ARN` → new output ARN (`gurujix-github-actions-ecr`)
2. Keep `ECR_PUBLISH=true`
3. Push to `main` to verify publish

Trust `sub` is locked to:
`repo:gurujix-tech@299745487/service-orders@1358132490:ref:refs/heads/main`
