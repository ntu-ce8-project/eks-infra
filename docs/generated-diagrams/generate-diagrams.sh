#!/usr/bin/env bash

generate_ecosystem_diagram() {
  mkdir -p ecosystem
  kubectl get all -A -o yaml | kube-diagrams -o ecosystem/ecosystem.png -
}

generate_namespace_diagrams() {
  namespaces=(
    "cert-manager"
    "default"
    "external-dns"
    "grafana-cloud"
    "ingress-nginx"
    "karpenter-loadtest"
    "kube-node-lease"
    "kube-public"
    "kube-system"
    "shop-staging"
  )

  for namespace in "${namespaces[@]}"; do
    output_dir="$namespace"
    output_file="$output_dir/$namespace.png"

    mkdir -p "$output_dir"
    kubectl get all -n "$namespace" -o yaml | kube-diagrams -o "$output_file" -
    echo "Diagram for $namespace saved to $output_file"
  done
}

generate_shop_diagrams() {
  shop_namespace="shop-staging"
  labels=(
    "carts"
    "catalog"
    "checkout"
    "orders"
    "ui"
  )

  mkdir -p "$shop_namespace"

  for label in "${labels[@]}"; do
    output_file="${shop_namespace}/${label}.png"

    kubectl get all -n "$shop_namespace" -l "app.kubernetes.io/name=$label" -o yaml | kube-diagrams -o "$output_file" -
    echo "Diagram for $label in $shop_namespace saved to $output_file"
  done
}

# Generate the diagrams
generate_ecosystem_diagram
generate_namespace_diagrams
generate_shop_diagrams
