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
# ROLE & BUCKETS FOR LOKI 
###############################

resource "aws_s3_bucket" "loki_chunks" {
  count = var.enable_loki_s3 ? 1 : 0

  bucket_prefix = "${local.prefix}-loki-chunks-sctp"
  force_destroy = true
}

resource "aws_s3_bucket" "loki_ruler" {
  count = var.enable_loki_s3 ? 1 : 0

  bucket_prefix = "${local.prefix}-loki-ruler-sctp"
  force_destroy = true
}

module "loki_s3_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.52.1"

  count = var.enable_loki_s3 ? 1 : 0

  create_role                    = true
  role_name                      = "${local.prefix}-loki-s3-oidc-role"
  provider_url                   = module.eks.oidc_provider
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  provider_trust_policy_conditions = [
    {
      test     = "StringLike"
      values   = ["system:serviceaccount:*:loki"]
      variable = "${module.eks.oidc_provider}:sub"
    }
  ]

  inline_policy_statements = [
    {
      actions = [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ]
      effect = "Allow"
      resources = [
        "${aws_s3_bucket.loki_chunks[0].arn}",
        "${aws_s3_bucket.loki_chunks[0].arn}/*",
        "${aws_s3_bucket.loki_ruler[0].arn}",
        "${aws_s3_bucket.loki_ruler[0].arn}/*"
      ]
    }
  ]

  depends_on = [aws_s3_bucket.loki_chunks, aws_s3_bucket.loki_ruler]
}

