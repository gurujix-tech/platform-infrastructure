# Destroy / teardown (cost control)

EKS control plane is ~$0.10/hr; ALB is hourly too. Tear down when idle.

## Safe order (EKS + GitOps + ALB)

1. **Stop app traffic / ALB** (so LBC deletes the load balancer):
   ```sh
   # Option A — remove Ingress by suspending the app Application (UI), or:
   kubectl -n argocd delete application service-orders
   # wait until Ingress/ALB gone:
   kubectl get ingress -A
   aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerName' --output text
   ```
2. **Optional:** delete LBC Application (or leave it; destroying EKS removes it anyway):
   ```sh
   kubectl -n argocd delete application aws-load-balancer-controller
   kubectl -n argocd delete application platform-gitops-eks-root
   ```
3. **Disable EKS** (keeps VPC) or full destroy:
   ```sh
   cd platform-infrastructure/live/ops
   terraform apply -var='enable_eks=false'
   # or: terraform destroy
   ```
4. Leave **bootstrap** (state bucket) unless you are done with the account stack entirely.

## GoDaddy

You can leave the `app` CNAME pointing at an old ALB name; it will NXDOMAIN/fail until you recreate. Or delete the `app` CNAME when tearing down for the day. **Do not** change NS records.

## Destroy live/ops fully

```sh
cd live/ops
terraform destroy
```

## Destroy bootstrap (rare)

1. Remove `lifecycle.prevent_destroy` from `bootstrap/main.tf` if you truly want to delete the bucket.
2. Empty the versioned bucket (including prior versions and `.tflock` objects).
3. `cd bootstrap && terraform destroy`

**Warning:** destroying the state bucket loses remote state unless you have backups.

## Kind vs AWS

`kind delete cluster --name gurujix` does **not** stop AWS spend. Always tear down EKS/ALB via the steps above.
