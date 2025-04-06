#!/bin/bash

export CLUSTER_NAME=$(cd ../../terraform/eks-cluster && terraform output -raw cluster_name)
export CLUSTER_ENDPOINT=$(cd ../../terraform/eks-cluster && terraform output -raw cluster_endpoint)
export EXTERNAL_DNS_ROLE_ARN=$(cd ../../terraform/eks-cluster && terraform output -json external_dns_role_arn | jq -r '.[0]')
export KARPENTER_CONTROLLER_ROLE_ARN=$(cd ../../terraform/eks-cluster && terraform output -raw karpenter_controller_role_arn)
export KARPENTER_NODE_ROLE_ARN=$(cd ../../terraform/eks-cluster && terraform output -raw karpenter_node_role_arn)
export KARPENTER_NODE_ROLE_NAME=$(cd ../../terraform/eks-cluster && terraform output -raw karpenter_node_role_name)
export KARPENTER_NODE_INSTANCE_PROFILE_NAME=$(cd ../../terraform/eks-cluster && terraform output -raw karpenter_node_instance_profile_name)
export KARPENTER_SQS_QUEUE_NAME=$(cd ../../terraform/eks-cluster && terraform output -raw karpenter_sqs_queue_name)