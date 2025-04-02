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

  # bucket_prefix = "${local.prefix}-loki-chunks-sctp"
  bucket        = "${local.prefix}-loki-chunks-sctp"
  force_destroy = true
}

resource "aws_s3_bucket" "loki_ruler" {
  count = var.enable_loki_s3 ? 1 : 0

  # bucket_prefix = "${local.prefix}-loki-ruler-sctp"
  bucket        = "${local.prefix}-loki-ruler-sctp"
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

###############################
# ROLE FOR KARPENTER 
###############################

resource "aws_iam_policy" "karpenter_controller" {
  name        = "KarpenterController"
  path        = "/"
  description = "Karpenter controller policy for autoscaling"
  policy      = <<EOF
{
    "Statement": [
        {
            "Action": [
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:RunInstances",
                "ec2:CreateTags",
                "ec2:TerminateInstances",
                "ec2:DeleteLaunchTemplate",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeSpotPriceHistory",
                "iam:PassRole",
                "ssm:GetParameter",
                "pricing:GetProducts"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "Karpenter"
        },
        {
            "Action": "ec2:TerminateInstances",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/Name": "*karpenter*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "ConditionalEC2Termination"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterNodeRole-${module.eks.cluster_name}",
            "Sid": "PassNodeIAMRole"
        },
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${module.eks.cluster_name}",
            "Sid": "eksClusterEndpointLookup"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile"
  role = module.eks.eks_managed_node_groups.regular.iam_role_name
}

module "karpenter_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "5.32.1"
  role_name = "karpenter_controller"

  role_policy_arns = {
    policy = aws_iam_policy.karpenter_controller.arn
  }

  karpenter_controller_cluster_id         = module.eks.cluster_id
  karpenter_controller_node_iam_role_arns = [module.eks.eks_managed_node_groups["regular"].iam_role_arn]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:karpenter"]
    }
  }
}