output "oidc_role_arn" {
  description = "GitHub role ARN"
  value       = module.github-oidc.oidc_role
}