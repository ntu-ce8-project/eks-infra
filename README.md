## Introduction

Note that this repository is used as an EKS demo repository for lessons.

## Pre-Requisites

Note that you have the following tools installed prior to using this repo:

- AWS CLI with a configured profile
- terraform
- kubectl
- helm

## File/Folder Structure in GIT

| File / Folder Name | Usage / Purpose |
| --- | --- |
| terraform-learner-cluster/ | This folder contains the required terraform files to create your AWS EKS cluster.  |
| demo-examples/ | Contains the required manifest files for the introductory k8s lessons on the how to create a basic deployment & the different types of services |
| ingress-externaldns-certmanager/ | Contains the manifest files to create a Nginx Ingress Controller, with ExternalDNS to Route53 & LetsEncrypt cert with cert-manager. (Note that you'll need to create your ExternalDNS IRSA as part of your terraform stack) |
| kube-prometheus-stack/ | Contains the manifest files for deploying a kube-prometheus stack along with the helm-values for the students |
| logging-stack/ | Contains the manifest files for deploying a loki grafana stack along with the helm-values for the students (Note that you'll need to create your Loki IRSA & S3 buckets as part of your terraform stack) |
