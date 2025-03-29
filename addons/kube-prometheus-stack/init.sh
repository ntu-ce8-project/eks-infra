#!/usr/bin/env bash

# 1. Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update repos to ensure we have the latest charts
helm repo update

# 2. Install or upgrade prometheus
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --atomic \
  --version 69.6.0 \
  --create-namespace \
  --namespace monitoring \
  --values values.yaml


