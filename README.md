## Introduction

Note that this repository is used as an EKS demo repository for lessons.

## Prerequisites

Tools installed:
 - AWS CLI
 - eksctl
 - kubectl

## Creating EKS Cluster

You may use Terraform or any IaC tool to create EKS. However to keep costs low & simple, I'm creating the cluster using eksctl using the below command:


``` eksctl create cluster --name <your-name>-eks-cluster --nodes 2 --instance-types=t2.micro ```
