data "aws_caller_identity" "current" {}

# data "aws_iam_openid_connect_provider" "oidc_provider" {
#   arn = "arn:aws:iam::${data.aws_caller_identity.current.id}:oidc-provider/token.actions.githubusercontent.com"
# }

# data "aws_iam_policy_document" "oidc" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]

#     principals {
#       type        = "Federated"
#       identifiers = [data.aws_iam_openid_connect_provider.oidc_provider.arn]
#     }

#     # condition {
#     #   test     = "StringEquals"
#     #   values   = ["sts.amazonaws.com"]
#     #   variable = "token.actions.githubusercontent.com:aud"
#     # }

#     condition {
#       test     = "StringLike"
#       values   = ["repo:ntu-ce8-project/eks-infra:*"]
#       variable = "token.actions.githubusercontent.com:sub"
#     }
#   }
# }