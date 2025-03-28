helm repo add lifecycle-toolkit https://charts.lifecycle.keptn.sh

helm repo update

helm upgrade --install my-keptn lifecycle-toolkit/keptn --version 0.11.0 \
  --create-namespace \
  --namespace keptn \
  --values values.yaml
