module "ebs_csi_driver_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.52.1"

  count = var.enable_ebs_csi_driver_role ? 1 : 0

  create_role                    = true
  role_name                      = "ebs-csidriver-role"
  provider_url                   = module.eks.oidc_provider
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  provider_trust_policy_conditions = [
    {
      test     = "StringLike"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
      variable = "${module.eks.oidc_provider}:sub"
    }
  ]
}
