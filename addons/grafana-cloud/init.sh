helm repo add grafana https://grafana.github.io/helm-charts

helm repo update

helm upgrade --install grafana-k8s-monitoring grafana/k8s-monitoring \
    --version ^2 \
    --atomic \
    --namespace "grafana-cloud" \
    --create-namespace \
    --values values.yaml
