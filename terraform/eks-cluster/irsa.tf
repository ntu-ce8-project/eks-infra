###############################
# ROLE FOR EXTERNAL DNS
###############################
module "external_dns_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.52.1"

  count = var.enable_external_dns ? 1 : 0

  create_role                    = true
  role_name                      = "${local.prefix}-externaldns-oidc-role"
  provider_url                   = module.eks.oidc_provider
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  provider_trust_policy_conditions = [
    {
      test     = "StringLike"
      values   = ["system:serviceaccount:*:external-dns"]
      variable = "${module.eks.oidc_provider}:sub"
    }
  ]

  inline_policy_statements = [
    {
      actions = [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResource"
      ]
      effect    = "Allow"
      resources = ["*"]
    },
    {
      actions = [
        "route53:ChangeResourceRecordSets"
      ]
      effect    = "Allow"
      resources = ["arn:aws:route53:::hostedzone/*"]
    }
  ]
}

###############################
# ROLE FOR EBS CSI DRIVER
###############################

module "ebs_csi_driver_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.52.1"

  count = var.enable_ebs_csi_driver_role ? 1 : 0

  create_role                    = true
  role_name                      = "${local.prefix}-ebs-csidriver-role"
  provider_url                   = module.eks.oidc_provider
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  provider_trust_policy_conditions = [
    {
      test     = "StringLike"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
      variable = "${module.eks.oidc_provider}:sub"
    }
  ]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
  ]
}

###############################
# ROLE FOR KARPENTER 
###############################

resource "aws_iam_instance_profile" "karpenter" {
  name = "${local.prefix}-KarpenterNodeInstanceProfile"
  role = module.eks.eks_managed_node_groups.CE8-G1-capstone-eks-ng.iam_role_name
}
