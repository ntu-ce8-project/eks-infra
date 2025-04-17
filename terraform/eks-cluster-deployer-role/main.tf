locals {
  # Ignored when create_oidc_provider is set to true
  account_id = data.aws_caller_identity.current.account_id
  oidc_provider_arn = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 2.2.1"

  create_oidc_provider = var.create_oidc_provider
  oidc_provider_arn    = local.oidc_provider_arn
  
  create_oidc_role     = true

  role_name = "github_oidc_role_ce8_capstone_G1"

  repositories              = ["ntu-ce8-project/eks-infra"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
