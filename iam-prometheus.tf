
data "aws_iam_policy_document" "allow_assume_web_identity" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:monitoring:prometheus"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "prometheus_remote_writer" {
  assume_role_policy = data.aws_iam_policy_document.allow_assume_web_identity.json
  name               = "${local.cluster_name}-prometheus-remote-writer"
}


resource "aws_iam_policy" "prometheus_eks_ingest_access" {
  name = "${local.cluster_name}-PrometheusEKSIngestAccess"

  policy = jsonencode({
    Statement = [{
      Action = [
        "aps:RemoteWrite"
      ]
      Effect   = "Allow"
      Resource = aws_prometheus_workspace.prometheus_eks.arn
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_eks_ingest_access" {
  role       = aws_iam_role.prometheus_remote_writer.name
  policy_arn = aws_iam_policy.prometheus_eks_ingest_access.arn
}

