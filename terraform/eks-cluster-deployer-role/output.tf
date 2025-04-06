output "account_id" {
  description = "account id"
  value       = data.aws_caller_identity.current.account_id
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = module.github-oidc.oidc_provider_arn
}

output "oidc_role_arn" {
  description = "OIDC role_role ARN"
  value       = module.github-oidc.oidc_role
}