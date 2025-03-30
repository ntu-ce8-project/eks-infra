#!/usr/bin/env bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

# We may need to install a standalone prometheus chart first with a different values.yaml

# helm upgrade --install prometheus prometheus-community/prometheus \
#   --atomic \
#   --version 27.7.1 \
#   --create-namespace \
#   --namespace monitoring \
#   --values values.yaml

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --atomic \
  --version 69.6.0 \
  --create-namespace \
  --namespace monitoring \
  --values values.yaml
