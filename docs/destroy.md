# Destroy / teardown (cost control)

## Safe order (later, when VPC/EKS exist)

1. Drain / destroy **workload** stacks first (EKS node groups, load balancers).
2. Destroy **cluster / network** stacks.
3. Leave **bootstrap** (state bucket + lock table) until you are sure you will not apply again.

## Destroy live/ops (smoke stack)

```sh
cd live/ops
terraform destroy
```

This only removes whatever `live/ops` manages (today: nothing billable beyond API calls).

## Destroy bootstrap (rare)

1. Remove `lifecycle.prevent_destroy` from `bootstrap/main.tf` in a PR if you truly want to delete the bucket.
2. Empty the versioned bucket (including prior versions) or Terraform destroy may fail.
3. `cd bootstrap && terraform destroy`

**Warning:** destroying the state bucket loses the source of truth for remote stacks unless you have backups.

## Kind vs AWS

Tearing down **kind** (`kind delete cluster --name gurujix`) does **not** destroy AWS resources. Always `terraform destroy` (or targeted destroys) for cloud spend.
