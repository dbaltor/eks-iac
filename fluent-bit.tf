resource "aws_iam_role" "fluent_bit" {
  name        = "fluent-bit"
  description = "IAM role used by fluent-bit inside EKS clusters"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
            }
          }
          Effect = "Allow",
          Principal = {
            Federated = module.eks.oidc_provider_arn
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  depends_on = [module.eks]
}

resource "aws_iam_policy" "es_domain_access" {
  name = "ESDomainAccess"
  description = "IAM policy for fluentbit"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          # ## Required by CloudWatch
          # "logs:PutLogEvents",
          # "logs:Describe*",
          # "logs:CreateLogStream",
          # "logs:CreateLogGroup",
          # "logs:PutRetentionPolicy",
          
          ## Required by ES
          "es:*"
        ]
        Effect   = "Allow"
        Resource = "${var.opensearch_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluent_bit_es_domain_access" {
  role       = aws_iam_role.fluent_bit.name
  policy_arn = aws_iam_policy.es_domain_access.arn
}

resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.30"
  namespace  = var.monitoring_namespace

  values = [templatefile("${path.module}/fluent-bit/values.yaml", {
      role_arn = aws_iam_role.fluent_bit.arn
      region = var.region
      domain_endpoint = var.opensearch_domain
      index = local.cluster_name
  })]

  depends_on = [
    module.eks_blueprints_addons,
    aws_iam_role.fluent_bit
  ]
}
