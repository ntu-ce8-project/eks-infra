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

# resource "aws_s3_bucket" "loki_chunks" {
#   count = var.enable_loki_s3 ? 1 : 0

#   # bucket_prefix = "${local.prefix}-loki-chunks-sctp"
#   bucket        = "${local.prefix}-loki-chunks-sctp"
#   force_destroy = true
# }

# resource "aws_s3_bucket" "loki_ruler" {
#   count = var.enable_loki_s3 ? 1 : 0

#   # bucket_prefix = "${local.prefix}-loki-ruler-sctp"
#   bucket        = "${local.prefix}-loki-ruler-sctp"
#   force_destroy = true
# }

# module "loki_s3_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version = "~> 5.52.1"

#   count = var.enable_loki_s3 ? 1 : 0

#   create_role                    = true
#   role_name                      = "${local.prefix}-loki-s3-oidc-role"
#   provider_url                   = module.eks.oidc_provider
#   oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

#   provider_trust_policy_conditions = [
#     {
#       test     = "StringLike"
#       values   = ["system:serviceaccount:*:loki"]
#       variable = "${module.eks.oidc_provider}:sub"
#     }
#   ]

#   inline_policy_statements = [
#     {
#       actions = [
#         "s3:ListBucket",
#         "s3:PutObject",
#         "s3:GetObject",
#         "s3:DeleteObject"
#       ]
#       effect = "Allow"
#       resources = [
#         "${aws_s3_bucket.loki_chunks[0].arn}",
#         "${aws_s3_bucket.loki_chunks[0].arn}/*",
#         "${aws_s3_bucket.loki_ruler[0].arn}",
#         "${aws_s3_bucket.loki_ruler[0].arn}/*"
#       ]
#     }
#   ]

#   depends_on = [aws_s3_bucket.loki_chunks, aws_s3_bucket.loki_ruler]
# }

###############################
# ROLE FOR KARPENTER 
###############################

# Role for ServiceAccount to use
# module "iam_assumable_role_karpenter" {
#   source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version                       = "4.7.0"

#   create_role                   = true
#   role_name                     = "${local.prefix}-karpenter-controller"
#   provider_url                  = module.eks.oidc_provider
#   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:karpenter"]
# }

resource "aws_iam_role" "karpenter_node_role" {
  name = "${local.prefix}-KarpenterNodeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "karpenter_node_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])

  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = each.value
}


# resource "AWS_iam_policy" "karpenter_controller" {
#   name        = "KarpenterControllerPolicy"
#   path        = "/"
#   description = "Karpenter controller policy with all necessary permissions"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "AllowScopedEC2InstanceAccessActions",
#       "Effect": "Allow",
#       "Action": [
#         "ec2:RunInstances",
#         "ec2:CreateFleet"
#       ],
#       "Resource": [
#         "arn:aws:ec2:${var.region}::image/*",
#         "arn:aws:ec2:${var.region}::snapshot/*",
#         "arn:aws:ec2:${var.region}:*:security-group/*",
#         "arn:aws:ec2:${var.region}:*:subnet/*",
#         "arn:aws:ec2:${var.region}:*:capacity-reservation/*"
#       ]
#     },
#     {
#       "Sid": "AllowScopedEC2LaunchTemplateAccessActions",
#       "Effect": "Allow",
#       "Action": [
#         "ec2:RunInstances",
#         "ec2:CreateFleet"
#       ],
#       "Resource": "arn:aws:ec2:${var.region}:*:launch-template/*",
#       "Condition": {
#         "StringEquals": {
#           "aws:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_name}": "owned"
#         },
#         "StringLike": {
#           "aws:ResourceTag/karpenter.sh/nodepool": "*"
#         }
#       }
#     },
#     {
#       "Sid": "AllowScopedEC2InstanceActionsWithTags",
#       "Effect": "Allow",
#       "Action": [
#         "ec2:RunInstances",
#         "ec2:CreateFleet",
#         "ec2:CreateLaunchTemplate"
#       ],
#       "Resource": [
#         "arn:aws:ec2:${var.region}:*:fleet/*",
#         "arn:aws:ec2:${var.region}:*:instance/*",
#         "arn:aws:ec2:${var.region}:*:volume/*",
#         "arn:aws:ec2:${var.region}:*:network-interface/*",
#         "arn:aws:ec2:${var.region}:*:launch-template/*",
#         "arn:aws:ec2:${var.region}:*:spot-instances-request/*",
#         "arn:aws:ec2:${var.region}:*:capacity-reservation/*"
#       ],
#       "Condition": {
#         "StringEquals": {
#           "aws:RequestTag/kubernetes.io/cluster/${module.eks.cluster_name}": "owned",
#           "aws:RequestTag/eks:eks-cluster-name": "${module.eks.cluster_name}"
#         },
#         "StringLike": {
#           "aws:RequestTag/karpenter.sh/nodepool": "*"
#         }
#       }
#     },
#     {
#       "Sid": "AllowScopedResourceCreationTagging",
#       "Effect": "Allow",
#       "Action": "ec2:CreateTags",
#       "Resource": [
#         "arn:aws:ec2:${var.region}:*:fleet/*",
#         "arn:aws:ec2:${var.region}:*:instance/*",
#         "arn:aws:ec2:${var.region}:*:volume/*",
#         "arn:aws:ec2:${var.region}:*:network-interface/*",
#         "arn:aws:ec2:${var.region}:*:launch-template/*",
#         "arn:aws:ec2:${var.region}:*:spot-instances-request/*"
#       ],
#       "Condition": {
#         "StringEquals": {
#           "aws:RequestTag/kubernetes.io/cluster/${module.eks.cluster_name}": "owned",
#           "aws:RequestTag/eks:eks-cluster-name": "${module.eks.cluster_name}",
#           "ec2:CreateAction": [
#             "RunInstances",
#             "CreateFleet",
#             "CreateLaunchTemplate"
#           ]
#         },
#         "StringLike": {
#           "aws:RequestTag/karpenter.sh/nodepool": "*"
#         }
#       }
#     },
#     {
#       "Sid": "AllowScopedResourceTagging",
#       "Effect": "Allow",
#       "Action": "ec2:CreateTags",
#       "Resource": "arn:aws:ec2:${var.region}:*:instance/*",
#       "Condition": {
#         "StringEquals": {
#           "aws:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_name}": "owned"
#         },
#         "StringLike": {
#           "aws:ResourceTag/karpenter.sh/nodepool": "*"
#         },
#         "StringEqualsIfExists": {
#           "aws:RequestTag/eks:eks-cluster-name": "${module.eks.cluster_name}"
#         },
#         "ForAllValues:StringEquals": {
#           "aws:TagKeys": [
#             "eks:eks-cluster-name",
#             "karpenter.sh/nodeclaim",
#             "Name"
#           ]
#         }
#       }
#     },
#     {
#       "Sid": "AllowScopedDeletion",
#       "Effect": "Allow",
#       "Action": [
#         "ec2:TerminateInstances",
#         "ec2:DeleteLaunchTemplate"
#       ],
#       "Resource": [
#         "arn:aws:ec2:${var.region}:*:instance/*",
#         "arn:aws:ec2:${var.region}:*:launch-template/*"
#       ],
#       "Condition": {
#         "StringEquals": {
#           "aws:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_name}": "owned"
#         },
#         "StringLike": {
#           "aws:ResourceTag/karpenter.sh/nodepool": "*"
#         }
#       }
#     },
#     {
#       "Sid": "AllowRegionalReadActions",
#       "Effect": "Allow",
#       "Action": [
#         "ec2:DescribeCapacityReservations",
#         "ec2:DescribeImages",
#         "ec2:DescribeInstances",
#         "ec2:DescribeInstanceTypeOfferings",
#         "ec2:DescribeInstanceTypes",
#         "ec2:DescribeLaunchTemplates",
#         "ec2:DescribeSecurityGroups",
#         "ec2:DescribeSpotPriceHistory",
#         "ec2:DescribeSubnets"
#       ],
#       "Resource": "*",
#       "Condition": {
#         "StringEquals": {
#           "aws:RequestedRegion": "${var.region}"
#         }
#       }
#     },
#     {
#       "Sid": "AllowSSMReadActions",
#       "Effect": "Allow",
#       "Action": "ssm:GetParameter",
#       "Resource": "arn:aws:ssm:${var.region}::parameter/aws/service/*"
#     },
#     {
#       "Sid": "AllowPricingReadActions",
#       "Effect": "Allow",
#       "Action": "pricing:GetProducts",
#       "Resource": "*"
#     },
#     {
#       "Sid": "AllowInterruptionQueueActions",
#       "Effect": "Allow",
#       "Action": [
#         "sqs:DeleteMessage",
#         "sqs:GetQueueUrl",
#         "sqs:ReceiveMessage"
#       ],
#       "Resource": "${KarpenterInterruptionQueue.Arn}"
#     },
#     {
#       "Sid": "AllowPassingInstanceRole",
#       "Effect": "Allow",
#       "Action": "iam:PassRole",
#       "Resource": "${KarpenterNodeRole.Arn}",
#       "Condition": {
#         "StringEquals": {
#           "iam:PassedToService": [
#             "ec2.amazonaws.com",
#             "ec2.amazonaws.com.cn"
#           ]
#         }
#       }
#     },
#     {
#       "Sid": "AllowScopedInstanceProfileCreationActions",
#       "Effect": "Allow",
#       "Action": [
#         "iam:CreateInstanceProfile"
#       ],
#       "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*",
#       "Condition": {
#         "StringEquals": {
#           "aws:RequestTag/kubernetes.io/cluster/${module.eks.cluster_name}": "owned",
#           "aws:RequestTag/eks:eks-cluster-name": "${module.eks.cluster_name}",
#           "aws:RequestTag/topology.kubernetes.io/region": "${var.region}"
#         },
#         "StringLike": {
#           "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
#         }
#       }
#     },
#     {
#       "Sid": "AllowScopedInstanceProfileTagActions",
#       "Effect": "Allow",
#       "Action": [
#         "iam:TagInstanceProfile"
#       ],
#       "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*",
#       "Condition": {
#         "StringEquals": {
#           "aws:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_name}": "owned",
#           "aws:ResourceTag/topology.kubernetes.io/region": "${var.region}",
#           "aws:RequestTag/kubernetes.io/cluster/${module.eks.cluster_name}": "owned",
#           "aws:RequestTag/eks:eks-cluster-name": "${module.eks.cluster_name}",
#           "aws:RequestTag/topology.kubernetes.io/region": "${var.region}"
#         },
#         "StringLike": {
#           "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
#           "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
#         }
#       }
#     },
#     {
#       "Sid": "AllowScopedInstanceProfileActions",
#       "Effect": "Allow",
#       "Action": [
#         "iam:AddRoleToInstanceProfile",
#         "iam:RemoveRoleFromInstanceProfile",
#         "iam:DeleteInstanceProfile"
#       ],
#       "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*",
#       "Condition": {
#         "StringEquals": {
#           "aws:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_name}": "owned",
#           "aws:ResourceTag/topology.kubernetes.io/region": "${var.region}"
#         },
#         "StringLike": {
#           "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
#         }
#       }
#     },
#     {
#       "Sid": "AllowInstanceProfileReadActions",
#       "Effect": "Allow",
#       "Action": "iam:GetInstanceProfile",
#       "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
#     },
#     {
#       "Sid": "AllowAPIServerEndpointDiscovery",
#       "Effect": "Allow",
#       "Action": "eks:DescribeCluster",
#       "Resource": "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${module.eks.cluster_name}"
#     }
#   ]
# }
# EOF
# }



# resource "aws_iam_policy" "karpenter_controller" {
#   name        = "${local.prefix}-KarpenterController"
#   path        = "/"
#   description = "Karpenter controller policy for autoscaling"
#   policy      = <<EOF
# {
#     "Statement": [
#         {
#             "Action": [
#                 "ec2:CreateLaunchTemplate",
#                 "ec2:CreateFleet",
#                 "ec2:RunInstances",
#                 "ec2:CreateTags",
#                 "ec2:TerminateInstances",
#                 "ec2:DeleteLaunchTemplate",
#                 "ec2:DescribeLaunchTemplates",
#                 "ec2:DescribeInstances",
#                 "ec2:DescribeSecurityGroups",
#                 "ec2:DescribeSubnets",
#                 "ec2:DescribeImages",
#                 "ec2:DescribeInstanceTypes",
#                 "ec2:DescribeInstanceTypeOfferings",
#                 "ec2:DescribeAvailabilityZones",
#                 "ec2:DescribeSpotPriceHistory",
#                 "iam:PassRole",
#                 "ssm:GetParameter",
#                 "pricing:GetProducts"
#             ],
#             "Effect": "Allow",
#             "Resource": "*",
#             "Sid": "Karpenter"
#         },
#         {
#             "Action": "ec2:TerminateInstances",
#             "Condition": {
#                 "StringLike": {
#                     "ec2:ResourceTag/Name": "*karpenter*"
#                 }
#             },
#             "Effect": "Allow",
#             "Resource": "*",
#             "Sid": "ConditionalEC2Termination"
#         },
#         {
#             "Effect": "Allow",
#             "Action": "iam:PassRole",
#             "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterNodeRole-${module.eks.cluster_name}",
#             "Sid": "PassNodeIAMRole"
#         },
#         {
#             "Effect": "Allow",
#             "Action": "eks:DescribeCluster",
#             "Resource": "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${module.eks.cluster_name}",
#             "Sid": "eksClusterEndpointLookup"
#         }
#     ],
#     "Version": "2012-10-17"
# }
# EOF
# }

# resource "aws_iam_instance_profile" "karpenter" {
#   name = "${local.prefix}-KarpenterNodeInstanceProfile"
#   role = module.eks.eks_managed_node_groups.CE8-G1-capstone-eks-ng.iam_role_name
# }

# module "karpenter_irsa_role" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version   = "5.32.1"
#   role_name = "${local.prefix}-karpenter_controller"

#   role_policy_arns = {
#     policy = aws_iam_policy.karpenter_controller_policy.arn
#   }

#   karpenter_controller_cluster_id         = module.eks.cluster_id
#   karpenter_controller_node_iam_role_arns = [module.eks.eks_managed_node_groups["CE8-G1-capstone-eks-ng"].iam_role_arn]

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:karpenter"]
#     }
#   }
# }

resource "aws_sqs_queue" "karpenter_interruption_queue" {
  name                      = module.eks.cluster_name
  message_retention_seconds = 300
  kms_master_key_id         = "alias/aws/sqs"
}

resource "aws_sqs_queue_policy" "karpenter_interruption_queue_policy" {
  queue_url = aws_sqs_queue.karpenter_interruption_queue.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter_interruption_queue.arn
      },
      {
        Sid      = "DenyHTTP"
        Effect   = "Deny"
        Action   = "sqs:*"
        Resource = aws_sqs_queue.karpenter_interruption_queue.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
      }
    ]
  })
}

# resource "aws_cloudwatch_event_rule" "scheduled_change_rule" {
#   name        = "ScheduledChangeRule"
#   description = "Rule to handle AWS Health Events"
#   event_pattern = jsonencode({
#     source      = ["aws.health"]
#     detail-type = ["AWS Health Event"]
#   })
# }

# resource "aws_cloudwatch_event_target" "scheduled_change_target" {
#   rule = aws_cloudwatch_event_rule.scheduled_change_rule.name
#   arn  = aws_sqs_queue.karpenter_interruption_queue.arn
# }

# resource "aws_cloudwatch_event_rule" "spot_interruption_rule" {
#   name        = "SpotInterruptionRule"
#   description = "Rule to handle EC2 Spot Instance Interruption Warnings"
#   event_pattern = jsonencode({
#     source      = ["aws.ec2"]
#     detail-type = ["EC2 Spot Instance Interruption Warning"]
#   })
# }

# resource "aws_cloudwatch_event_target" "spot_interruption_target" {
#   rule = aws_cloudwatch_event_rule.spot_interruption_rule.name
#   arn  = aws_sqs_queue.karpenter_interruption_queue.arn
# }

# resource "aws_cloudwatch_event_rule" "rebalance_rule" {
#   name        = "RebalanceRule"
#   description = "Rule to handle EC2 Instance Rebalance Recommendations"
#   event_pattern = jsonencode({
#     source      = ["aws.ec2"]
#     detail-type = ["EC2 Instance Rebalance Recommendation"]
#   })
# }

# resource "aws_cloudwatch_event_target" "rebalance_target" {
#   rule = aws_cloudwatch_event_rule.rebalance_rule.name
#   arn  = aws_sqs_queue.karpenter_interruption_queue.arn
# }

# resource "aws_cloudwatch_event_rule" "instance_state_change_rule" {
#   name        = "InstanceStateChangeRule"
#   description = "Rule to handle EC2 Instance State-change Notifications"
#   event_pattern = jsonencode({
#     source      = ["aws.ec2"]
#     detail-type = ["EC2 Instance State-change Notification"]
#   })
# }

# resource "aws_cloudwatch_event_target" "instance_state_change_target" {
#   rule = aws_cloudwatch_event_rule.instance_state_change_rule.name
#   arn  = aws_sqs_queue.karpenter_interruption_queue.arn
# }