helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

helm upgrade --install argocd argo/argo-cd \
  --atomic \
  --namespace argocd --create-namespace \
  --values values.yaml
