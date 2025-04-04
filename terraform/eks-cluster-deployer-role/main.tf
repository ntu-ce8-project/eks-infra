module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 2.2.1"

  create_oidc_provider = true
  # create_oidc_provider = false
  create_oidc_role     = true

  role_name = "github_oidc_role_ce8_capstone_G1"

  repositories              = ["ntu-ce8-project/eks-infra"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}


