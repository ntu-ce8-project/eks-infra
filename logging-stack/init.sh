#!/usr/bin/env bash

# 1. Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update repos to ensure we have the latest charts
helm repo update

# 2. Install or upgrade loki
helm install --values values.yaml loki grafana/loki -n loki --create-namespace

# 3. Install or upgrade promtail
helm install promtail grafana/promtail --version 6.7.4

