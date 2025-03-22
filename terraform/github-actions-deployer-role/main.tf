module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 2.2.1"

  create_oidc_provider = true
  create_oidc_role     = true

  role_name = "github-actions-eks-demo-role"

  repositories              = ["jaezeu/eks-demo"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}