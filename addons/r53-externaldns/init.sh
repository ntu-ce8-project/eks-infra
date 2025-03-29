#!/usr/bin/env bash

helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/

helm repo update

helm upgrade --install external-dns external-dns/external-dns \
  --atomic \
  --namespace external-dns \
  --create-namespace \
  --values values.yaml
