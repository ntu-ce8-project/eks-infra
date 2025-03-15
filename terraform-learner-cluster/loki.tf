resource "aws_s3_bucket" "loki_chunks" {
  count = var.enable_loki_s3 ? 1 : 0

  bucket_prefix = "loki-chunks-sctp"
  force_destroy = true
}

resource "aws_s3_bucket" "loki_ruler" {
  count = var.enable_loki_s3 ? 1 : 0

  bucket_prefix = "loki-ruler-sctp"
  force_destroy = true
}

module "loki_s3_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.52.1"

  count = var.enable_loki_s3 ? 1 : 0

  create_role                    = true
  role_name                      = "loki-s3-oidc-role"
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
