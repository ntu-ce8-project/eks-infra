output "account_id" {
  description = "account id"
  value       = data.aws_caller_identity.current.account_id
}

# output "caller_arn" {
#   value = data.aws_caller_identity.current.arn
# }

# output "caller_user" {
#   value = data.aws_caller_identity.current.user_id
# }

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = data.aws_iam_openid_connect_provider.oidc_provider.arn
}

# output "oidc_policy_document" {
#   description = "value of the policy document"
#   value = data.aws_iam_policy_document.oidc.json
# }

output "oidc_role_name" {
  description = "Role name"
  value       = aws_iam_role.this.name
}

output "oidc_role_arn" {
  description = "Role ARN"
  value       = aws_iam_role.this.arn

}