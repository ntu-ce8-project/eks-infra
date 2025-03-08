#!/usr/bin/env bash

# 1. Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update repos to ensure we have the latest charts
helm repo update

# 2. Install or upgrade prometheus
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 69.6.0 \
  --create-namespace \
  --set controller.metrics.enabled=true \
  --values helm-values/kube-prometheus-stack.yaml
helm install promtail grafana/promtail --version 6.7.4
helm install loki grafana/loki --version 2.15.2 --values loki.yaml


