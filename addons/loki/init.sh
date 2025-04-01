#!/usr/bin/env bash

# 1. Add Helm repositories
helm repo add grafana https://grafana.github.io/helm-charts

# Update repos to ensure we have the latest charts
helm repo update

# 1.5 Initialise Loki Canary with username and password
kubectl create secret generic canary-basic-auth --from-literal=username=admin --from-literal=password=$(openssl rand -base64 12) -n loki

# 2. Install or upgrade loki
helm upgrade --install  loki grafana/loki \
  --namespace loki \
  --create-namespace \
  --values values.yaml 

# 3. Install or upgrade promtail
helm upgrade --install promtail grafana/promtail \
  --atomic \
  --version 6.7.4 \
  --namespace loki \
  --create-namespace \
  --values prom-values.yaml
