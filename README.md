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
| terraform/ | This folder contains the required terraform files to create your AWS EKS cluster. Refer to the comments within the TF files |
| deployment-manifest-examples/ | Contains the required manifest files for the introductory k8s lessons on the how to create a basic deployment & the different types of services, along with netshoot pod for troubleshooting & kyverno policy for instructor to protect specific resources. |
| addons/ | Contains the required helm charts to bootstrap your cluster. manifest files to bootstrap your cluster. You may refer to the ```README.md``` file within the folder how to install charts with dependencies. |
