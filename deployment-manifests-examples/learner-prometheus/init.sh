helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# 2. Install or upgrade prometheus
helm upgrade --install learner-prom prometheus-community/prometheus --version 69.6.0 \
  --create-namespace \
  --namespace learner-prom \
  --values prometheus.yaml