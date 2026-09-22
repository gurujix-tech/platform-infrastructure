# Bootstrap → remote state

## Why two folders?

| Path | Backend | Job |
| --- | --- | --- |
| `bootstrap/` | **Local** `.tfstate` on your machine (gitignored) | Create the S3 state bucket |
| `live/ops/` | **Remote** S3 + `use_lockfile` | All future infra; state shared / locked |

You cannot store Terraform state in a bucket that does not exist yet — hence bootstrap once.

Locking: Terraform **>= 1.10** native S3 lockfile (no DynamoDB).

## Steps

1. `aws sts get-caller-identity` (correct account).
2. `cd bootstrap && terraform init && terraform apply`
3. `terraform output backend_hcl_example` → save as `live/ops/backend.hcl`
4. `cd ../live/ops && terraform init -backend-config=backend.hcl && terraform apply`

## Protect the bootstrap state

- Keep a backup of `bootstrap/terraform.tfstate` somewhere safe (encrypted personal store), or migrate bootstrap state into the new bucket later as an advanced step.
- Bucket has `prevent_destroy` — deleting state infrastructure is intentional and rare.
