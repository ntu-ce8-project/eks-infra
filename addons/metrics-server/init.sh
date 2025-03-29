#!/usr/bin/env bash

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

helm upgrade --install metrics-server metrics-server/metrics-server \
  --atomic \
  --namespace kube-system \
  --create-namespace \
  --values values.yaml
