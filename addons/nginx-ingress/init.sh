#!/usr/bin/env bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --atomic \
  --namespace ingress-nginx \
  --create-namespace \
  --values values.yaml
