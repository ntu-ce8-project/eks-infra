# To create a new OIDC provider:
# terraform plan -var "create_oidc_provider=true" -out tfplan
# terraform apply tfplan

# Set to true to create a new OIDC provider for GitHub Actions
variable "create_oidc_provider" {
  type    = bool
  default = false 
}
