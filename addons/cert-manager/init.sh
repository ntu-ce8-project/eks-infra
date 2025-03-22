#!/usr/bin/env bash

helm repo add jetstack https://charts.jetstack.io

helm repo update

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  --values values.yaml

kubectl apply -f cluster-issuer.yaml

