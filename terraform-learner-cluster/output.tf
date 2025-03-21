output "cluster_name" {
  value       = module.eks.cluster_name
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

output "loki_s3_role_arn" {
  value = module.loki_s3_role[*].iam_role_arn
}

output "loki_chunks_bucket_arn" {
  value = aws_s3_bucket.loki_chunks[*].arn
}

output "loki_ruler_bucket_arn" {
  value = aws_s3_bucket.loki_ruler[*].arn
}

output "ebs_csi_driver_role_arn" {
  value = module.ebs_csi_driver_role[*].iam_role_arn
}
