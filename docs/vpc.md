# Phase 8b — VPC (learning footprint)

## What you get

| Piece | Notes |
| --- | --- |
| VPC `10.42.0.0/16` (`Name=gurujix-platform`) | DNS hostnames + support on; `Component=network` |
| 2 public + 2 private subnets | Across first 2 AZs in the region |
| Internet Gateway | Public subnet default route |
| NAT Gateway | **Off by default** (`enable_nat_gateway = false`) |
| Subnet tags | `kubernetes.io/role/elb` / `internal-elb` for future EKS |

## Apply (DIY)

```sh
cd live/ops
terraform plan
terraform apply
terraform output
```

Enable NAT only when private subnets need egress:

```sh
terraform apply -var='enable_nat_gateway=true'
```

Destroy when idle (NAT is the main cost if enabled):

```sh
terraform destroy
```

Or destroy just network later with targeted destroys once more resources exist — see `destroy.md`.
