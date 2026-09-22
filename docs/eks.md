# Phase 8c — EKS (learning footprint)

## What you get

| Piece | Choice |
| --- | --- |
| Cluster `gurujix-platform` | Public + private API endpoint; creator gets admin via access API |
| Node group | 1× `t3.medium` in **public** subnets (no NAT required) |
| Toggle | `enable_eks=false` removes cluster/nodes but keeps the VPC |

Control plane ≈ **$0.10/hr**. Destroy or disable when idle.

## Apply

```sh
cd live/ops
terraform plan
terraform apply
terraform output eks_configure_kubectl
```

Then:

```sh
aws eks update-kubeconfig --region us-east-1 --name gurujix-platform
kubectl get nodes
```

## Tear down compute (keep VPC)

```sh
terraform apply -var='enable_eks=false'
```

## Full destroy

```sh
terraform destroy
```
