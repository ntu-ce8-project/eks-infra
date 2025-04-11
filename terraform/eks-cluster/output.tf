output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "external_dns_role_arn" {
  value = module.external_dns_role[*].iam_role_arn
}

output "karpenter_node_role_arn" {
  value = module.karpenter.node_iam_role_arn
}

output "karpenter_node_role_name" {
  value = module.karpenter.node_iam_role_name
}

output "karpenter_controller_role_arn" {
  value = module.karpenter.iam_role_arn
}

output "karpenter_node_instance_profile_name" {
  value = aws_iam_instance_profile.karpenter.id
}

output "karpenter_sqs_queue_name" {
  value = module.karpenter.queue_name
}
output "ebs_csi_driver_role_arn" {
  value = module.ebs_csi_driver_role[*].iam_role_arn
}
