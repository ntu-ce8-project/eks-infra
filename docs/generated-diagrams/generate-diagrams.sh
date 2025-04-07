#!/bin/bash

mkdir -p ecosystem

kubectl get all -A -o yaml | kube-diagrams -o ecosystem/ecosystem.png -

namespaces=("cert-manager" "default" "external-dns" "grafana-cloud" "ingress-nginx" "karpenter-loadtest" "kube-node-lease" "kube-public" "kube-system" "shop-staging")
label_namespaces=("shop-staging") # Namespaces to process with labels
labels=("carts" "catalog" "checkout" "orders" "ui")

# Namespace based diagrams
for namespace in "${namespaces[@]}"; do
  output_dir="$namespace"
  output_file="$output_dir/$namespace.png"

  # Create the output directory if it doesn't exist
  mkdir -p "$output_dir"

  kubectl get all -n "$namespace" -o yaml | kube-diagrams -o "$output_file" -
  echo "Diagram for $namespace saved to $output_file"
done

# Label based diagrams
for namespace in "${label_namespaces[@]}"; do
  for label in "${labels[@]}"; do
    output_dir="$namespace"
    output_file="$output_dir/${label}.png"

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    kubectl get all -n "$namespace" -l "app.kubernetes.io/name=$label" -o yaml | kube-diagrams -o "$output_file" -
    echo "Diagram for $label in $namespace saved to $output_file"
  done
done