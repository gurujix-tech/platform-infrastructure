# Destroy / teardown (cost control)

## Safe order

1. Disable/destroy **EKS** first (`terraform apply -var='enable_eks=false'` or full destroy).
2. Then VPC / remaining `live/ops` resources.
3. Leave **bootstrap** (state bucket) until you are sure you will not apply again.

## Destroy live/ops

```sh
cd live/ops
terraform destroy
```

Or keep the VPC and only drop compute:

```sh
terraform apply -var='enable_eks=false'
```

EKS control plane is ~$0.10/hr — do not leave it idle overnight without intent.

## Destroy bootstrap (rare)

1. Remove `lifecycle.prevent_destroy` from `bootstrap/main.tf` in a PR if you truly want to delete the bucket.
2. Empty the versioned bucket (including prior versions and any `.tflock` objects) or Terraform destroy may fail.
3. `cd bootstrap && terraform destroy`

**Warning:** destroying the state bucket loses the source of truth for remote stacks unless you have backups.

## Kind vs AWS

Tearing down **kind** (`kind delete cluster --name gurujix`) does **not** destroy AWS resources. Always `terraform destroy` (or targeted destroys) for cloud spend.
