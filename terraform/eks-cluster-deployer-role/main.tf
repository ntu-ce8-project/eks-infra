module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 2.2.1"

# if you want to create the OIDC provider for GitHub Actions, set this to true
  create_oidc_provider = true
# if you want to attac an existing OIDC provider for GitHub Actions, set this to false and provide the ARN
#   create_oidc_provider = false
#   oidc_provider_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  
  create_oidc_role     = true

  role_name = "github_oidc_role_ce8_capstone_G1"

  repositories              = ["ntu-ce8-project/eks-infra"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}