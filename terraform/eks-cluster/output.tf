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
  value = aws_iam_role.karpenter_node_role.arn
}

output "karpenter_node_role_name" {
  value = aws_iam_role.karpenter_node_role.id
}

output "karpenter_controller_role_arn" {
  value = module.karpenter_irsa_role.iam_role_arn
}

output "karpenter_node_instance_profile_name" {
  value = aws_iam_instance_profile.karpenter.id
} 

output "karpenter_sqs_queue_name" {
  value = aws_sqs_queue.karpenter_interruption_queue.name
}

# output "loki_s3_role_arn" {
#   value = module.loki_s3_role[*].iam_role_arn
# }

# output "loki_chunks_bucket_arn" {
#   value = aws_s3_bucket.loki_chunks[*].arn
# }

# output "loki_ruler_bucket_arn" {
#   value = aws_s3_bucket.loki_ruler[*].arn
# }

output "ebs_csi_driver_role_arn" {
  value = module.ebs_csi_driver_role[*].iam_role_arn
}

# output "merged_users" {
#   description = "List of all users and groups that have been merged to create a single list of users"
#   value       = local.merged_users
# }

# output "allowed_usernames" {
#   value = local.allowed_usernames
# }

# output "merged_users_filtered" {
#   value = local.filtered_users
# }
