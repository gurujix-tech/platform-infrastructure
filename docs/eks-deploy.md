# Deploy service-orders to EKS from ECR

Learning path: Helm install (no Argo on EKS yet). Kind + Argo stay as the local path.

## Prerequisites

- EKS up: `kubectl get nodes`
- Image in ECR (CI push to `main` with `ECR_PUBLISH=true`)

```sh
aws eks update-kubeconfig --region us-east-1 --name gurujix-platform
aws ecr describe-images --repository-name service-orders --region us-east-1 \
  --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags' --output text
```

## Install

```sh
cd service-orders
TAG=<git-sha-from-ecr>   # e.g. from describe-images or GitHub Actions

helm upgrade --install service-orders deploy/helm/service-orders \
  -n default \
  -f deploy/helm/service-orders/values.yaml \
  -f deploy/helm/service-orders/values-eks.yaml \
  --set image.tag="${TAG}"

kubectl get pods -l app.kubernetes.io/name=service-orders
kubectl port-forward svc/service-orders 8080:80
# curl -s localhost:8080/health
```

## Uninstall

```sh
helm uninstall service-orders -n default
```

## Later

- Argo CD on EKS pointing at GitOps
- Ingress / ALB + `app.gurujix.com` using the ACM cert
